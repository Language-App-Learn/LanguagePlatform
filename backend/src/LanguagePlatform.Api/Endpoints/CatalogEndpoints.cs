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

        group.MapGet("/courses", async (ILearningCatalogService service, HttpContext context,
                string? source, string? target, Guid? learningPathId, Guid? programId, string? locale,
                string? after, int? limit, CancellationToken cancellationToken) =>
            {
                var page = await service.GetCoursesAsync(
                    new CourseQuery(source, target, learningPathId, programId, locale, after, limit ?? 20), cancellationToken);
                if (page.NextCursor is { } next) context.Response.Headers["X-Next-Cursor"] = next;
                return TypedResults.Ok(page.Items);
            })
            .WithName("GetCatalogCourses")
            .ProducesProblem(StatusCodes.Status400BadRequest);

        group.MapGet("/courses/{id:guid}", async (Guid id, string? locale,
                ILearningCatalogService service, CancellationToken cancellationToken) =>
            {
                var course = await service.FindCourseAsync(id, locale, cancellationToken);
                return course is null ? Results.Problem(statusCode: 404) : Results.Ok(course);
            })
            .WithName("GetCatalogCourse")
            .Produces<CourseDto>()
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status404NotFound);

        return endpoints;
    }
}
