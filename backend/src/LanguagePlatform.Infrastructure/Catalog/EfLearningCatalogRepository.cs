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
        await dbContext.EligiblePaths()
            .Include(path => path.SourceLanguage)
            .Include(path => path.TargetLanguage)
            .OrderBy(path => path.SourceLanguage.Code)
            .ThenBy(path => path.TargetLanguage.Code)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken) =>
        await dbContext.LearningPrograms
            .AsNoTracking()
            .Where(program => dbContext.IncludeLegacyContent || (program.IsActive && program.Code == "modern-language"))
            .OrderBy(program => program.Code)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<CourseDto>> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken)
    {
        var courses = dbContext.PublishedCourses();
        if (query.Source is { } source)
        {
            var code = LanguageCode.Create(source);
            courses = courses.Where(x => x.LearningPath.SourceLanguage.Code == code);
        }
        if (query.Target is { } target)
        {
            var code = LanguageCode.Create(target);
            courses = courses.Where(x => x.LearningPath.TargetLanguage.Code == code);
        }
        if (query.LearningPathId is { } pathId) courses = courses.Where(x => x.LearningPathId == pathId);
        if (query.ProgramId is { } programId) courses = courses.Where(x => x.LearningProgramId == programId);
        // EF translates this comparison with the same database collation as ORDER BY.
#pragma warning disable CA1309
        if (query.After is { } cursor) courses = courses.Where(x => string.Compare(x.Slug, cursor) > 0);
#pragma warning restore CA1309
        return await Project(courses.OrderBy(x => x.Slug).Take(query.Limit + 1)).ToListAsync(cancellationToken);
    }

    public Task<CourseDto?> FindCourseAsync(Guid id, CancellationToken cancellationToken) =>
        Project(dbContext.PublishedCourses().Where(x => x.Id == id)).SingleOrDefaultAsync(cancellationToken);

    private IQueryable<CourseDto> Project(IQueryable<Course> courses) => courses.AsSplitQuery()
        .Select(course => new CourseDto(course.Id, course.LearningPathId, course.LearningProgramId,
            course.Slug, course.Title, course.Description, "Published")
        {
            SourceLanguageCode = course.LearningPath.SourceLanguage.Code.Value,
            TargetLanguageCode = course.LearningPath.TargetLanguage.Code.Value,
            Localizations = (from translation in dbContext.Set<CourseLocalization>()
                join language in dbContext.Languages on translation.LanguageId equals language.Id
                where translation.CourseId == course.Id && language.IsActive
                orderby language.Code
                select new CourseTranslationDto(language.Code.Value, translation.Title, translation.Description)).ToList(),
            Levels = dbContext.Set<CourseLevel>().Where(level => level.CourseId == course.Id)
                .OrderBy(level => level.DisplayOrder).Select(level =>
                    new CourseLevelDto(level.Id, level.Code, level.DisplayOrder)).ToList()
        });
}
