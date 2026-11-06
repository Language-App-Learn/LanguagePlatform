using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CourseCategoryAssignment : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required Guid CourseCategoryId { get; init; }
}

