using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class CourseLocalization : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required Guid LanguageId { get; init; }
    public required string Title { get; init; }
    public string? Description { get; init; }
}
