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

    public async Task<IReadOnlyList<CourseDto>> GetCoursesAsync(CancellationToken cancellationToken)
    {
        var courses = await repository.GetCoursesAsync(cancellationToken);
        return courses.Select(course => new CourseDto(
            course.Id,
            course.LearningPathId,
            course.LearningProgramId,
            course.Slug,
            course.Title,
            course.Description,
            course.Status.ToString())).ToArray();
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
