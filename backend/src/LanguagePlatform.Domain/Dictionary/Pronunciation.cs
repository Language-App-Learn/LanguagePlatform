using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class Pronunciation : PlatformEntity
{
    public required Guid DictionaryEntryId { get; init; }
    public required Guid MediaAssetId { get; init; }
    public required string DialectCode { get; init; }
    public string? PhoneticText { get; init; }
}
