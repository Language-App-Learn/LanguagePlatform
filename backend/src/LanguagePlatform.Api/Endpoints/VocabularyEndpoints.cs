using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Dictionary;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.Dictionary;

namespace LanguagePlatform.Api.Endpoints;

public static class VocabularyEndpoints
{
    public static void MapVocabularyEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/v1/me/vocabulary").RequireAuthorization().WithTags("Vocabulary");
        group.MapGet("", async (Guid? targetLanguageId, bool? favoritesOnly, int? offset, int? limit,
            ICurrentActor actor, VocabularyService service, CancellationToken ct) =>
            actor.UserId is { } userId
                ? Results.Ok(await service.ListAsync(userId, targetLanguageId, favoritesOnly == true, new OutlineQuery(offset ?? 0, limit ?? 50), ct))
                : Results.Unauthorized())
            .Produces<VocabularyPage>().ProducesProblem(400).ProducesProblem(401);
        group.MapGet("/{id:guid}", async (Guid id, ICurrentActor actor, VocabularyService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } userId) return Results.Unauthorized();
            var detail = await service.FindAsync(userId, id, ct);
            return detail is null ? Results.Problem(statusCode: 404) : Results.Ok(detail);
        }).Produces<VocabularyDetailDto>().ProducesProblem(401).ProducesProblem(404);
        group.MapPut("/{id:guid}/favorite", async (Guid id, UpdateFavorite request, ICurrentActor actor,
            VocabularyService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } userId) return Results.Unauthorized();
            return await service.SetFavoriteAsync(userId, id, request.IsFavorite, ct)
                ? Results.NoContent() : Results.Problem(statusCode: 404);
        }).Produces(204).ProducesProblem(401).ProducesProblem(404);
    }
}
