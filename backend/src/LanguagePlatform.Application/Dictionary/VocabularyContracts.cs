namespace LanguagePlatform.Application.Dictionary;

public sealed record VocabularyItemDto(Guid Id, string LanguageCode, string Lemma, string PartOfSpeech, bool IsFavorite);
public sealed record VocabularyPage(IReadOnlyList<VocabularyItemDto> Items, int? NextOffset);
public sealed record VocabularyTranslationDto(string LanguageCode, string Text);
public sealed record VocabularySenseDto(int Number, string Definition, IReadOnlyList<VocabularyTranslationDto> Translations);
public sealed record VocabularyDetailDto(VocabularyItemDto Word, IReadOnlyList<VocabularySenseDto> Senses);
public sealed record UpdateFavorite(bool IsFavorite);
