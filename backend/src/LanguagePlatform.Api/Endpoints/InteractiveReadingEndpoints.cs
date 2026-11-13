using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.CourseContent;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Net.Http.Headers;

namespace LanguagePlatform.Api.Endpoints;

public static class InteractiveReadingEndpoints
{
    internal const string UploadRatePolicy = "reading-audio-upload";

    public static void MapInteractiveReadingEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var teacher = endpoints.MapGroup("/api/v1/admin/five-stage/versions/{versionId:guid}/reading-pdf")
            .RequireAuthorization(Permissions.ContentEdit).WithTags("Interactive reading");
        teacher.MapPut("/lines/{lineId:guid}/reference-audio", async (Guid versionId, Guid lineId, uint expectedVersion,
            HttpRequest request, ICurrentActor actor, ReadingPdfService pdf, CancellationToken ct) =>
        {
            if (actor.UserId is not { } user) return Results.Unauthorized();
            if (ValidateAudioRequest(request) is { } error) return error;
            return Results.Ok(await pdf.SetReferenceAudioAsync(user, versionId, lineId, expectedVersion, request.Body, ct));
        }).Accepts<Stream>(ReadingWave.ContentType).RequireRateLimiting(UploadRatePolicy)
            .Produces<ReadingPdfDraftDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(403)
            .ProducesProblem(404).ProducesProblem(409).ProducesProblem(413).ProducesProblem(415).ProducesProblem(429);

        var student = endpoints.MapGroup("/api/v1/me/courses/{courseId:guid}/lessons/{lessonId:guid}/reading-progress")
            .RequireAuthorization().WithTags("Interactive reading");
        student.MapGet("", async (Guid courseId, Guid lessonId, ICurrentActor actor, HttpResponse response,
            InteractiveReadingService reading, CancellationToken ct) =>
        {
            if (actor.UserId is not { } user) return Results.Unauthorized();
            Private(response);
            return Present(await reading.GetProgressAsync(user, courseId, lessonId, ct));
        }).Produces<InteractiveReadingProgressDto>().ProducesProblem(401).ProducesProblem(404);

        student.MapGet("/lines/{lineId:guid}/reference-audio", async (Guid courseId, Guid lessonId, Guid lineId,
            HttpResponse response, ICurrentActor actor, InteractiveReadingService reading, CancellationToken ct) =>
        {
            if (actor.UserId is not { } user) return Results.Unauthorized();
            var audio = await reading.GetAudioAsync(user, courseId, lessonId, lineId, ct);
            if (audio is null) return Results.Problem(statusCode: 404);
            Private(response);
            response.Headers.XContentTypeOptions = "nosniff";
            return Results.File(audio, ReadingWave.ContentType);
        }).Produces<Stream>(StatusCodes.Status200OK, contentType: ReadingWave.ContentType)
            .ProducesProblem(401).ProducesProblem(404);

        student.MapPost("/lines/{lineId:guid}/evaluations", async (Guid courseId, Guid lessonId, Guid lineId,
            [FromHeader(Name = "Idempotency-Key")] Guid key, HttpRequest request, HttpResponse response,
            ICurrentActor actor, InteractiveReadingService reading, CancellationToken ct) =>
        {
            if (actor.UserId is not { } user) return Results.Unauthorized();
            if (ValidateAudioRequest(request) is { } error) return error;
            Private(response);
            var result = await reading.SubmitAsync(user, courseId, lessonId, lineId, key, request.Body, ct);
            return result is { Status: "PENDING" }
                ? Results.Accepted($"/api/v1/me/courses/{courseId}/lessons/{lessonId}/reading-progress/evaluations/{result.Id}", result)
                : Present(result);
        }).Accepts<Stream>(ReadingWave.ContentType).RequireRateLimiting(UploadRatePolicy)
            .Produces<ReadingLineEvaluationDto>().Produces<ReadingLineEvaluationDto>(StatusCodes.Status202Accepted)
            .ProducesProblem(400).ProducesProblem(401).ProducesProblem(404).ProducesProblem(409)
            .ProducesProblem(413).ProducesProblem(415).ProducesProblem(429);

        student.MapGet("/evaluations/{evaluationId:guid}", async (Guid courseId, Guid lessonId, Guid evaluationId,
            ICurrentActor actor, HttpResponse response, InteractiveReadingService reading, CancellationToken ct) =>
        {
            if (actor.UserId is not { } user) return Results.Unauthorized();
            Private(response);
            return Present(await reading.GetEvaluationAsync(user, courseId, lessonId, evaluationId, ct));
        }).Produces<ReadingLineEvaluationDto>().ProducesProblem(401).ProducesProblem(404);
    }

    private static IResult? ValidateAudioRequest(HttpRequest request)
    {
        if (!MediaTypeHeaderValue.TryParse(request.ContentType, out var mediaType) ||
            !string.Equals(mediaType.MediaType.Value, ReadingWave.ContentType, StringComparison.OrdinalIgnoreCase))
            return Results.Problem(statusCode: 415);
        return request.ContentLength > ReadingWave.MaximumBytes ? Results.Problem(statusCode: 413) : null;
    }

    private static IResult Present<T>(T? value) where T : class =>
        value is null ? Results.Problem(statusCode: 404) : Results.Ok(value);

    private static void Private(HttpResponse response) => response.Headers.CacheControl = "private, no-store";
}
