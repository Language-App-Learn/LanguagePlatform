using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class LessonLocalization : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required Guid LanguageId { get; init; }
    public required string Title { get; init; }
    public string? Description { get; init; }
}
