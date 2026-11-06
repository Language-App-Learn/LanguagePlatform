using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class DictionaryEntry : PlatformEntity
{
    public required Guid LanguageId { get; init; }
    public Guid? RootId { get; init; }
    public required string Lemma { get; init; }
    public required string NormalizedLemma { get; init; }
    public required string PartOfSpeech { get; init; }
}

