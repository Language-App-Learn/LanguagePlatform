using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Application.Catalog;

public interface ILearningCatalogRepository
{
    Task<IReadOnlyList<Language>> GetLanguagesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningPath>> GetLearningPathsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<CourseDto>> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken);
    Task<CourseDto?> FindCourseAsync(Guid id, CancellationToken cancellationToken);
}
