using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Catalog;

public sealed class EfLearningCatalogRepository(LanguagePlatformDbContext dbContext) : ILearningCatalogRepository
{
    public async Task<IReadOnlyList<Language>> GetLanguagesAsync(CancellationToken cancellationToken) =>
        await dbContext.Languages
            .AsNoTracking()
            .OrderBy(language => language.Code)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<LearningPath>> GetLearningPathsAsync(CancellationToken cancellationToken) =>
        await dbContext.LearningPaths
            .AsNoTracking()
            .Include(path => path.SourceLanguage)
            .Include(path => path.TargetLanguage)
            .OrderBy(path => path.SourceLanguage.Code)
            .ThenBy(path => path.TargetLanguage.Code)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken) =>
        await dbContext.LearningPrograms
            .AsNoTracking()
            .OrderBy(program => program.Code)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Course>> GetCoursesAsync(CancellationToken cancellationToken) =>
        await dbContext.Courses
            .AsNoTracking()
            .OrderBy(course => course.Slug)
            .ToListAsync(cancellationToken);
}
