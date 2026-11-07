using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Application.Catalog;

public sealed class LearningCatalogService(ILearningCatalogRepository repository) : ILearningCatalogService
{
    public async Task<IReadOnlyList<LanguageDto>> GetLanguagesAsync(CancellationToken cancellationToken)
    {
        var languages = await repository.GetLanguagesAsync(cancellationToken);
        return languages.Select(MapLanguage).ToArray();
    }

    public async Task<IReadOnlyList<LearningPathDto>> GetLearningPathsAsync(CancellationToken cancellationToken)
    {
        var paths = await repository.GetLearningPathsAsync(cancellationToken);
        return paths.Select(path => new LearningPathDto(
            path.Id,
            MapLanguageSummary(path.SourceLanguage),
            MapLanguageSummary(path.TargetLanguage),
            path.IsActive)).ToArray();
    }

    public async Task<IReadOnlyList<LearningProgramDto>> GetProgramsAsync(CancellationToken cancellationToken)
    {
        var programs = await repository.GetProgramsAsync(cancellationToken);
        return programs.Select(program => new LearningProgramDto(
            program.Id,
            program.Code,
            program.Name,
            program.ProgramType.Value,
            program.IsActive)).ToArray();
    }

    public async Task<CoursePage> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken)
    {
        query = query.Validate();
        var courses = await repository.GetCoursesAsync(query, cancellationToken);
        var items = courses.Take(query.Limit).Select(course => Localize(course, query.Locale)).ToArray();
        return new CoursePage(items, courses.Count > query.Limit ? items[^1].Slug : null);
    }

    public async Task<CourseDto?> FindCourseAsync(Guid id, string? locale, CancellationToken cancellationToken)
    {
        var query = new CourseQuery(Locale: locale).Validate();
        var course = await repository.FindCourseAsync(id, cancellationToken);
        return course is null ? null : Localize(course, query.Locale);
    }

    private static CourseDto Localize(CourseDto course, string? locale)
    {
        var parent = locale?.Split('-')[0];
        var candidates = new[] { locale, parent, "en" }.Distinct(StringComparer.Ordinal);
        var translations = candidates.Select(code => course.Localizations.FirstOrDefault(x => x.Locale == code))
            .OfType<CourseTranslationDto>().ToArray();
        return course with
        {
            Title = translations.FirstOrDefault()?.Title ?? course.Title,
            Description = translations.FirstOrDefault(x => x.Description is not null)?.Description ?? course.Description
        };
    }

    private static LanguageDto MapLanguage(Language language) =>
        new(
            language.Id,
            language.Code.Value,
            language.Name,
            language.NativeName,
            language.TextDirection.ToString(),
            language.IsActive);

    private static LanguageSummaryDto MapLanguageSummary(Language language) =>
        new(language.Id, language.Code.Value, language.Name, language.NativeName);
}
