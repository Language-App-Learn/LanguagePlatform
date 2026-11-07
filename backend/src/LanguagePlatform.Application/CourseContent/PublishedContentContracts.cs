using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Application.CourseContent;

public sealed record LessonOutlineDto(Guid Id, Guid VersionId, int VersionNumber, string Title,
    Guid LevelId, string LevelCode, Guid ModuleId, string ModuleTitle, Guid UnitId, string UnitTitle, int Order);
public sealed record LessonOutlinePage(IReadOnlyList<LessonOutlineDto> Items, int? NextOffset);
public sealed record LessonTranslationDto(string Locale, string Title, string? Description);
public sealed record StageTextDto(string Locale, string Text);
public sealed record StageDto(Guid Id, string StageType, int Order, bool IsRequired, decimal Weight,
    decimal MinimumScore, int MaximumAttempts, int EstimatedDurationSeconds, IReadOnlyList<StageTextDto> Texts,
    Guid? AssessmentId);
public sealed record PublishedLessonDto(Guid Id, Guid CourseId, Guid VersionId, int VersionNumber, string Title,
    string TargetLanguageCode, int Order, decimal PassingScore, IReadOnlyList<LessonTranslationDto> Localizations,
    IReadOnlyList<StageDto> Stages);

public sealed record OutlineQuery(int Offset = 0, int Limit = 50)
{
    public void Validate() => Guard.Against(Offset < 0 || Offset > 100_000 || Limit is < 1 or > 100,
        "Offset must be between 0 and 100000 and limit between 1 and 100.");
}

public interface IPublishedContentQueries
{
    Task<LessonOutlinePage?> ListAsync(Guid courseId, OutlineQuery query, CancellationToken cancellationToken);
    Task<PublishedLessonDto?> FindAsync(Guid courseId, Guid lessonId, CancellationToken cancellationToken);
    Task<Guid?> FindVersionIdAsync(Guid courseId, Guid lessonId, CancellationToken cancellationToken);
}
