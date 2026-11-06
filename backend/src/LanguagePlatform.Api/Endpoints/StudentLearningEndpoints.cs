using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Infrastructure.StudentProgress;

namespace LanguagePlatform.Api.Endpoints;

public static class StudentLearningEndpoints
{
    public static void MapStudentLearningEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/v1/me/courses/{courseId:guid}").RequireAuthorization().WithTags("Learning Progress");
        group.MapPut("/enrollment", async (Guid courseId, ICurrentActor actor, StudentLearningService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            return Present(await service.EnrollAsync(id, courseId, ct));
        }).Produces<EnrollmentDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(404);

        group.MapGet("/progress", async (Guid courseId, ICurrentActor actor, StudentLearningService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            return Present(await service.GetCourseAsync(id, courseId, ct));
        }).Produces<CourseProgressDto>().ProducesProblem(401).ProducesProblem(404);

        group.MapGet("/lessons/progress", async (Guid courseId, int? offset, int? limit, bool? completedOnly,
            ICurrentActor actor, StudentLearningService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            return Present(await service.GetLessonsAsync(id, courseId, new OutlineQuery(offset ?? 0, limit ?? 50),
                completedOnly == true, ct));
        }).Produces<LessonProgressPage>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(404);

        group.MapPut("/lessons/{lessonId:guid}/start", async (Guid courseId, Guid lessonId,
            ICurrentActor actor, StudentLearningService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            return Present(await service.StartAsync(id, courseId, lessonId, ct));
        }).Produces<LessonProgressDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(404);
    }

    private static IResult Present<T>(T? value) where T : class =>
        value is null ? Results.Problem(statusCode: 404) : Results.Ok(value);
}
