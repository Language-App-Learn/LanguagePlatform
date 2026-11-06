using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class ContentPublication : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required Guid PublishedBy { get; init; }
    public required DateTime PublishedAtUtc { get; init; }
    public DateTime? WithdrawnAtUtc { get; init; }
    public string? Reason { get; init; }
}

