using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class Lesson : PlatformEntity
{
    public required Guid CourseUnitId { get; init; }
    public required string Slug { get; init; }
    public required int DisplayOrder { get; init; }
    public bool IsArchived { get; init; }
}

