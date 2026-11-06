using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CourseLevel : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required string Code { get; init; }
    public required int DisplayOrder { get; init; }
}

