using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class WordForm : PlatformEntity
{
    public required Guid DictionaryEntryId { get; init; }
    public required string Text { get; init; }
    public required string NormalizedText { get; init; }
    public required string FormType { get; init; }
}

