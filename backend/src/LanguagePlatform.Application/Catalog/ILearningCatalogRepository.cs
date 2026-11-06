using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Application.Catalog;

public interface ILearningCatalogRepository
{
    Task<IReadOnlyList<Language>> GetLanguagesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningPath>> GetLearningPathsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<Course>> GetCoursesAsync(CancellationToken cancellationToken);
}
