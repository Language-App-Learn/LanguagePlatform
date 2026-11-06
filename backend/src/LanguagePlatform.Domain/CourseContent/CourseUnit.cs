using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class CourseUnit : PlatformEntity
{
    public required Guid CourseModuleId { get; init; }
    public required string Title { get; init; }
    public required int DisplayOrder { get; init; }
}

