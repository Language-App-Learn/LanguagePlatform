namespace LanguagePlatform.Application.Catalog;

public sealed record LanguageDto(
    Guid Id,
    string Code,
    string Name,
    string NativeName,
    string TextDirection,
    bool IsActive);

public sealed record LanguageSummaryDto(Guid Id, string Code, string Name, string NativeName);

public sealed record LearningPathDto(
    Guid Id,
    LanguageSummaryDto SourceLanguage,
    LanguageSummaryDto TargetLanguage,
    bool IsActive);

public sealed record LearningProgramDto(
    Guid Id,
    string Code,
    string Name,
    string ProgramType,
    bool IsActive);

public sealed record CourseDto(
    Guid Id,
    Guid LearningPathId,
    Guid LearningProgramId,
    string Slug,
    string Title,
    string? Description,
    string Status)
{
    public string SourceLanguageCode { get; init; } = "";
    public string TargetLanguageCode { get; init; } = "";
    public IReadOnlyList<CourseTranslationDto> Localizations { get; init; } = [];
    public IReadOnlyList<CourseLevelDto> Levels { get; init; } = [];
}
