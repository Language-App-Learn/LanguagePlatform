using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.CourseContent;

namespace LanguagePlatform.Api.Endpoints;

public static class FiveStageEndpoints
{
    public static void MapFiveStageEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var publicCourses = endpoints.MapGroup("/api/v1/courses/{courseId:guid}/curriculum").WithTags("Five-stage curriculum");
        publicCourses.MapGet("/levels", async (Guid courseId, CurriculumQueries service, CancellationToken ct) =>
            Present(await service.LevelsAsync(courseId, false, ct))).Produces<CurriculumCourseDto>().ProducesProblem(404);
        publicCourses.MapGet("/levels/{levelId:guid}/slots", async (Guid courseId, Guid levelId, CurriculumQueries service, CancellationToken ct) =>
            Present(await service.SlotsAsync(courseId, levelId, false, ct))).Produces<IReadOnlyList<CurriculumSlotDto>>().ProducesProblem(404);

        var authors = endpoints.MapGroup("/api/v1/admin/five-stage").WithTags("Five-stage authoring")
            .RequireAuthorization(Permissions.ContentEdit);
        authors.MapPost("/courses", async (CreateCurriculumCourse request, CurriculumAuthoringService service, CancellationToken ct) =>
            TypedResults.Ok(await service.CreateCourseAsync(request, ct)))
            .ProducesProblem(400).ProducesProblem(401).ProducesProblem(403).ProducesProblem(409);
        authors.MapGet("/courses/{courseId:guid}/levels/{levelId:guid}/slots",
            async (Guid courseId, Guid levelId, CurriculumQueries service, CancellationToken ct) =>
                Present(await service.SlotsAsync(courseId, levelId, true, ct)))
            .Produces<IReadOnlyList<CurriculumSlotDto>>().ProducesProblem(401).ProducesProblem(403).ProducesProblem(404);
        authors.MapPost("/courses/{courseId:guid}/levels/{levelId:guid}/slots/{position:int}/versions",
            async (Guid courseId, Guid levelId, int position, CreateCurriculumVersion request,
                ICurrentActor actor, CurriculumAuthoringService service, CancellationToken ct) =>
                actor.UserId is { } id
                    ? Results.Ok(await service.CreateVersionAsync(id, courseId, levelId, position, request, ct))
                    : Results.Unauthorized())
            .Produces<CurriculumDraftDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(403)
            .ProducesProblem(404).ProducesProblem(409);
        authors.MapPost("/versions/{versionId:guid}/review", async (Guid versionId, ReviewCurriculumVersion request,
            CurriculumAuthoringService service, CancellationToken ct) =>
            TypedResults.Ok(await service.ReviewAsync(versionId, request.ExpectedVersion, ct)))
            .ProducesProblem(400).ProducesProblem(401).ProducesProblem(403).ProducesProblem(404).ProducesProblem(409);
    }

    private static IResult Present<T>(T? result) where T : class =>
        result is null ? Results.Problem(statusCode: 404) : Results.Ok(result);
}
