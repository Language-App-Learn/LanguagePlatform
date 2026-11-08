using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingVocabularyReference : PlatformEntity
{
    public required Guid ReadingTextSegmentId { get; init; }
    public required Guid DictionaryEntryId { get; init; }
}
