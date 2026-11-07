using LanguagePlatform.Domain.Common;
using LanguagePlatform.Application.Common;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;

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
            BadHttpRequestException => (StatusCodes.Status400BadRequest, "Invalid request."),
            UploadTooLargeException => (StatusCodes.Status413PayloadTooLarge, "Upload exceeds the allowed size."),
            PermissionDeniedException => (StatusCodes.Status403Forbidden, "Permission denied."),
            ResourceNotFoundException => (StatusCodes.Status404NotFound, "The requested resource was not found."),
            StateConflictException => (StatusCodes.Status409Conflict, "The requested action conflicts with current state."),
            DbUpdateConcurrencyException => (StatusCodes.Status409Conflict, "The resource changed. Reload it before retrying."),
            DbUpdateException { InnerException: PostgresException { SqlState: PostgresErrorCodes.UniqueViolation
                or PostgresErrorCodes.ForeignKeyViolation or PostgresErrorCodes.CheckViolation or PostgresErrorCodes.RestrictViolation } }
                => (StatusCodes.Status409Conflict, "The requested change conflicts with existing data."),
            _ => (StatusCodes.Status500InternalServerError, "An unexpected error occurred.")
        };

        if (statusCode >= StatusCodes.Status500InternalServerError)
        {
            LogUnhandledRequest(logger, exception.GetType().Name, httpContext.TraceIdentifier);
        }
        else
        {
            LogRejectedRequest(logger, statusCode, httpContext.TraceIdentifier);
        }

        httpContext.Response.StatusCode = statusCode;
        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = new ProblemDetails
            {
                Status = statusCode,
                Title = title,
                Detail = exception is DomainException or StateConflictException ? exception.Message : null,
                Instance = httpContext.Request.Path
            }
        });
    }

    [LoggerMessage(
        EventId = 1,
        Level = LogLevel.Error,
        Message = "Unhandled request failure of type {exceptionType}. Trace identifier: {traceIdentifier}")]
    private static partial void LogUnhandledRequest(ILogger logger, string exceptionType, string traceIdentifier);

    [LoggerMessage(
        EventId = 2,
        Level = LogLevel.Warning,
        Message = "Request failed with status {statusCode}. Trace identifier: {traceIdentifier}")]
    private static partial void LogRejectedRequest(ILogger logger, int statusCode, string traceIdentifier);
}
