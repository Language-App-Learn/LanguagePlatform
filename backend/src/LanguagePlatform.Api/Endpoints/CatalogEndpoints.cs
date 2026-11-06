using LanguagePlatform.Application.Catalog;

namespace LanguagePlatform.Api.Endpoints;

public static class CatalogEndpoints
{
    public static IEndpointRouteBuilder MapCatalogEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/v1/catalog")
            .WithTags("Learning Catalog");

        group.MapGet("/languages", async (ILearningCatalogService service, CancellationToken cancellationToken) =>
                Results.Ok(await service.GetLanguagesAsync(cancellationToken)))
            .WithName("GetCatalogLanguages")
            .Produces<IReadOnlyList<LanguageDto>>();

        group.MapGet("/learning-paths", async (ILearningCatalogService service, CancellationToken cancellationToken) =>
                Results.Ok(await service.GetLearningPathsAsync(cancellationToken)))
            .WithName("GetCatalogLearningPaths")
            .Produces<IReadOnlyList<LearningPathDto>>();

        group.MapGet("/programs", async (ILearningCatalogService service, CancellationToken cancellationToken) =>
                Results.Ok(await service.GetProgramsAsync(cancellationToken)))
            .WithName("GetCatalogPrograms")
            .Produces<IReadOnlyList<LearningProgramDto>>();

        group.MapGet("/courses", async (ILearningCatalogService service, CancellationToken cancellationToken) =>
                Results.Ok(await service.GetCoursesAsync(cancellationToken)))
            .WithName("GetCatalogCourses")
            .Produces<IReadOnlyList<CourseDto>>();

        return endpoints;
    }
}
