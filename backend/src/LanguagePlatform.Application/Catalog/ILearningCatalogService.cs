namespace LanguagePlatform.Application.Catalog;

public interface ILearningCatalogService
{
    Task<IReadOnlyList<LanguageDto>> GetLanguagesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningPathDto>> GetLearningPathsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningProgramDto>> GetProgramsAsync(CancellationToken cancellationToken);
    Task<CoursePage> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken);
    Task<CourseDto?> FindCourseAsync(Guid id, string? locale, CancellationToken cancellationToken);
}
