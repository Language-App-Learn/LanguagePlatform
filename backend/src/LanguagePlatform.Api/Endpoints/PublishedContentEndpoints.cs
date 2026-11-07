using LanguagePlatform.Application.CourseContent;

namespace LanguagePlatform.Api.Endpoints;

public static class PublishedContentEndpoints
{
    public static void MapPublishedContentEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var courses = endpoints.MapGroup("/api/v1/courses/{courseId:guid}").WithTags("Published Content");
        courses.MapGet("/lessons", async (Guid courseId, int? offset, int? limit,
            IPublishedContentQueries content, CancellationToken ct) =>
        {
            var page = await content.ListAsync(courseId, new OutlineQuery(offset ?? 0, limit ?? 50), ct);
            return page is null ? Results.Problem(statusCode: 404) : Results.Ok(page);
        }).Produces<LessonOutlinePage>().ProducesProblem(400).ProducesProblem(404);

        courses.MapGet("/lessons/{lessonId:guid}", async (Guid courseId, Guid lessonId,
            IPublishedContentQueries content, CancellationToken ct) =>
        {
            var lesson = await content.FindAsync(courseId, lessonId, ct);
            return lesson is null ? Results.Problem(statusCode: 404) : Results.Ok(lesson);
        }).Produces<PublishedLessonDto>().ProducesProblem(404);
    }
}
