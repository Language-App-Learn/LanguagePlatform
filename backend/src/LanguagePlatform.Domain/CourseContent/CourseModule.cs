using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class CourseModule : PlatformEntity
{
    public required Guid CourseLevelId { get; init; }
    public required string Title { get; init; }
    public required int DisplayOrder { get; init; }
}

