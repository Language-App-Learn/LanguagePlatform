using LanguagePlatform.Domain.Common;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Api.ErrorHandling;

public sealed partial class GlobalExceptionHandler(
    IProblemDetailsService problemDetailsService,
    ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var (statusCode, title) = exception switch
        {
            DomainException => (StatusCodes.Status400BadRequest, "A business rule was violated."),
            DbUpdateException => (StatusCodes.Status409Conflict, "The requested change conflicts with existing data."),
            _ => (StatusCodes.Status500InternalServerError, "An unexpected error occurred.")
        };

        if (statusCode >= StatusCodes.Status500InternalServerError)
        {
            LogUnhandledRequest(logger, exception, httpContext.TraceIdentifier);
        }
        else
        {
            LogRejectedRequest(logger, statusCode, httpContext.TraceIdentifier);
        }

        httpContext.Response.StatusCode = statusCode;
        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            Exception = exception,
            ProblemDetails = new ProblemDetails
            {
                Status = statusCode,
                Title = title,
                Detail = statusCode < StatusCodes.Status500InternalServerError ? exception.Message : null,
                Instance = httpContext.Request.Path
            }
        });
    }

    [LoggerMessage(
        EventId = 1,
        Level = LogLevel.Error,
        Message = "Unhandled request failure. Trace identifier: {traceIdentifier}")]
    private static partial void LogUnhandledRequest(ILogger logger, Exception exception, string traceIdentifier);

    [LoggerMessage(
        EventId = 2,
        Level = LogLevel.Warning,
        Message = "Request failed with status {statusCode}. Trace identifier: {traceIdentifier}")]
    private static partial void LogRejectedRequest(ILogger logger, int statusCode, string traceIdentifier);
}
