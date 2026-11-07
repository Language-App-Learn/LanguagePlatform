using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CoursePrerequisite : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required Guid RequiredCourseId { get; init; }
}
