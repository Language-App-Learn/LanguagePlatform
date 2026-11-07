using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class WordExample : PlatformEntity
{
    public required Guid WordSenseId { get; init; }
    public required string Text { get; init; }
    public string? SourceAttribution { get; init; }
    public string? VideoId { get; init; }
    public int? StartSeconds { get; init; }
    public int? EndSeconds { get; init; }
}
