using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CourseInstructor : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required Guid UserId { get; init; }
    public bool CanEdit { get; init; }
}
