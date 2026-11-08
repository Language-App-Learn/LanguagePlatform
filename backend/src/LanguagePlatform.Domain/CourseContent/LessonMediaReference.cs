using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class LessonMediaReference : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required Guid MediaAssetId { get; init; }
    public required string Purpose { get; init; }
}
