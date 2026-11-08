using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.Assessment;

namespace LanguagePlatform.Api.Endpoints;

public static class ObjectiveAssessmentEndpoints
{
    public static void MapObjectiveAssessmentEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/v1/me/courses/{courseId:guid}/lessons/{lessonId:guid}/assessments/{assessmentId:guid}/attempts")
            .RequireAuthorization().WithTags("Assessments");
        group.MapPost("", async (Guid courseId, Guid lessonId, Guid assessmentId, StartObjectiveAttempt request,
            ICurrentActor actor, ObjectiveAssessmentService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var attempt = await service.StartAsync(id, courseId, lessonId, assessmentId, request, ct);
            return attempt is null ? Results.Problem(statusCode: 404) : Results.Ok(attempt);
        }).Produces<ObjectiveAttemptDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(404).ProducesProblem(409);

        group.MapPost("/{attemptId:guid}/submit", async (Guid courseId, Guid lessonId, Guid assessmentId, Guid attemptId,
            SubmitObjectiveAttempt request, ICurrentActor actor, ObjectiveAssessmentService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var result = await service.SubmitAsync(id, courseId, lessonId, assessmentId, attemptId, request, ct);
            return result is null ? Results.Problem(statusCode: 404) : Results.Ok(result);
        }).Produces<ObjectiveResultDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(404).ProducesProblem(409);

        endpoints.MapGet("/api/v1/me/assessment-attempts/{attemptId:guid}/result", async (Guid attemptId,
            ICurrentActor actor, ObjectiveAssessmentService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } id) return Results.Unauthorized();
            var result = await service.FindResultAsync(id, attemptId, ct);
            return result is null ? Results.Problem(statusCode: 404) : Results.Ok(result);
        }).RequireAuthorization().WithTags("Assessments")
            .Produces<ObjectiveResultDto>().ProducesProblem(401).ProducesProblem(404);

        const string speaking = "/api/v1/admin/courses/{courseId:guid}/lessons/{lessonId:guid}/assessments/{assessmentId:guid}/attempts/{attemptId:guid}/speaking-evaluation";
        endpoints.MapGet(speaking,
            async (Guid courseId, Guid lessonId, Guid assessmentId, Guid attemptId,
                ICurrentActor actor, ObjectiveAssessmentService service, CancellationToken ct) =>
            {
                if (actor.UserId is not { } id) return Results.Unauthorized();
                var context = await service.GetSpeakingEvaluationAsync(id, courseId, lessonId, assessmentId, attemptId, ct);
                return context is null ? Results.Problem(statusCode: 404) : Results.Ok(context);
            }).RequireAuthorization(Permissions.AssessmentEvaluate).WithTags("Assessments")
            .Produces<SpeakingEvaluationContextDto>().ProducesProblem(401).ProducesProblem(403).ProducesProblem(404).ProducesProblem(409);
        endpoints.MapPost(speaking,
            async (Guid courseId, Guid lessonId, Guid assessmentId, Guid attemptId, EvaluateSpeaking request,
                ICurrentActor actor, ObjectiveAssessmentService service, CancellationToken ct) =>
            {
                if (actor.UserId is not { } id) return Results.Unauthorized();
                var result = await service.EvaluateSpeakingAsync(id, courseId, lessonId, assessmentId, attemptId, request, ct);
                return result is null ? Results.Problem(statusCode: 404) : Results.Ok(result);
            }).RequireAuthorization(Permissions.AssessmentEvaluate).WithTags("Assessments")
            .Produces<ObjectiveResultDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(403)
            .ProducesProblem(404).ProducesProblem(409);
    }
}
