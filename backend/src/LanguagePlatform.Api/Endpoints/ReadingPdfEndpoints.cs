using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.CourseContent;
using Microsoft.Net.Http.Headers;

namespace LanguagePlatform.Api.Endpoints;

public static class ReadingPdfEndpoints
{
    private const string Pdf = "application/pdf";
    internal const string UploadRatePolicy = "reading-pdf-upload";

    public static void MapReadingPdfEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var author = endpoints.MapGroup("/api/v1/admin/five-stage/versions/{versionId:guid}/reading-pdf")
            .WithTags("Reading materials").RequireAuthorization(Permissions.ContentEdit);
        author.MapPost("", async (Guid versionId, uint expectedVersion, string title, string copyrightNotice,
            HttpRequest request, ICurrentActor actor, ReadingPdfService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            if (!MediaTypeHeaderValue.TryParse(request.ContentType, out var type)
                || !string.Equals(type.MediaType.Value, Pdf, StringComparison.OrdinalIgnoreCase))
                return Results.Problem(statusCode: 415);
            if (request.ContentLength > ReadingPdfService.MaximumUploadBytes) return Results.Problem(statusCode: 413);
            return Results.Ok(await service.UploadAsync(id, versionId, expectedVersion, title, copyrightNotice, request.Body, ct));
        }).Accepts<Stream>(Pdf).RequireRateLimiting(UploadRatePolicy)
            .Produces<ReadingPdfDraftDto>().ProducesProblem(400).ProducesProblem(401)
            .ProducesProblem(403).ProducesProblem(404).ProducesProblem(409).ProducesProblem(413).ProducesProblem(415)
            .ProducesProblem(429);

        author.MapGet("", async (Guid versionId, ICurrentActor actor, ReadingPdfService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var draft = await service.GetDraftAsync(id, versionId, ct);
            return draft is null ? Results.Problem(statusCode: 404) : Results.Ok(draft);
        }).Produces<ReadingPdfDraftDto>().ProducesProblem(401).ProducesProblem(403).ProducesProblem(404);

        author.MapPut("/review", async (Guid versionId, ReviewReadingPdf request, ICurrentActor actor,
            ReadingPdfService service, CancellationToken ct) => actor.UserId is { } id
                ? Results.Ok(await service.ReviewAsync(id, versionId, request, ct)) : Results.Unauthorized())
            .Produces<ReadingPdfDraftDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(403)
            .ProducesProblem(404).ProducesProblem(409);

        author.MapGet("/original", async (Guid versionId, HttpResponse response, ICurrentActor actor,
            ReadingPdfService service, CancellationToken ct) => actor.UserId is { } id
                ? Download(await service.GetOwnerPdfAsync(id, versionId, ct), response) : Results.Unauthorized())
            .Produces(StatusCodes.Status200OK, contentType: Pdf).ProducesProblem(401).ProducesProblem(403).ProducesProblem(404);

        var student = endpoints.MapGroup("/api/v1/me/courses/{courseId:guid}/lessons/{lessonId:guid}")
            .WithTags("Reading materials").RequireAuthorization();
        student.MapGet("/reading-material", async (Guid courseId, Guid lessonId, ICurrentActor actor,
            ReadingPdfService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var material = await service.GetPublishedAsync(id, courseId, lessonId, ct);
            return material is null ? Results.Problem(statusCode: 404) : Results.Ok(material);
        }).Produces<ApprovedReadingDto>().ProducesProblem(401).ProducesProblem(404);

        student.MapGet("/reading-material/original", async (Guid courseId, Guid lessonId, HttpResponse response,
            ICurrentActor actor, ReadingPdfService service, CancellationToken ct) => actor.UserId is { } id
                ? Download(await service.GetPublishedPdfAsync(id, courseId, lessonId, ct), response) : Results.Unauthorized())
            .Produces(StatusCodes.Status200OK, contentType: Pdf).ProducesProblem(401).ProducesProblem(404);

        student.MapGet("/stages/{stageId:guid}/media", async (Guid courseId, Guid lessonId, Guid stageId,
            ICurrentActor actor, ReadingPdfService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var media = await service.GetStageMediaAsync(id, courseId, lessonId, stageId, ct);
            return media is null ? Results.Problem(statusCode: 404) : Results.Ok(media);
        }).Produces<CurriculumStageMediaDto>().ProducesProblem(401).ProducesProblem(404);
    }

    private static IResult Download(byte[]? original, HttpResponse response)
    {
        if (original is null) return Results.Problem(statusCode: 404);
        response.Headers.CacheControl = "private, no-store";
        response.Headers.XContentTypeOptions = "nosniff";
        return Results.File(original, Pdf, "lesson-source.pdf");
    }
}
