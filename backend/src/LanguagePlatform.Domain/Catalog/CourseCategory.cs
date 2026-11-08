using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CourseCategory : PlatformEntity
{
    public required string Code { get; init; }
    public required string Name { get; init; }
}
