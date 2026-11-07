using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class WordSense : PlatformEntity
{
    public required Guid DictionaryEntryId { get; init; }
    public required int SenseNumber { get; init; }
    public required string Definition { get; init; }
}
