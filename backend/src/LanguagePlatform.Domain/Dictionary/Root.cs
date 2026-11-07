using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class Root : PlatformEntity
{
    public required Guid LanguageId { get; init; }
    public required string Letters { get; init; }
    public string? Meaning { get; init; }
}
