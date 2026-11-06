using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Identity;

namespace LanguagePlatform.Api.Endpoints;

public static class AdminPublicationEndpoints
{
    public static void MapAdminPublicationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/api/v1/admin/lesson-versions/{versionId:guid}/publish",
            async (Guid versionId, PublishLessonRequest request, LessonPublicationService service, CancellationToken ct) =>
            {
                await service.PublishAsync(versionId, request.ExpectedVersion, ct);
                return TypedResults.NoContent();
            })
            .WithTags("Administration").RequireAuthorization(Permissions.ContentPublish)
            .ProducesProblem(400).ProducesProblem(401).ProducesProblem(403)
            .ProducesProblem(404).ProducesProblem(409);
    }
}

public sealed record PublishLessonRequest(uint ExpectedVersion);
