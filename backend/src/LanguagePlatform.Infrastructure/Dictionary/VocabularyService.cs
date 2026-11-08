using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Dictionary;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Dictionary;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Dictionary;

public sealed class VocabularyService(LanguagePlatformDbContext db, TimeProvider clock)
{
    public async Task<VocabularyPage> ListAsync(Guid userId, Guid? targetLanguageId, bool favoritesOnly,
        OutlineQuery query, CancellationToken ct)
    {
        query.Validate();
        var entries = Words(userId);
        if (targetLanguageId is { } target) entries = entries.Where(x => x.Language.Id == target);
        if (favoritesOnly) entries = entries.Where(x => x.IsFavorite);
        var rows = await entries.OrderBy(x => x.Entry.NormalizedLemma).ThenBy(x => x.Entry.Id)
            .Skip(query.Offset).Take(query.Limit + 1)
            .Select(x => new VocabularyItemDto(x.Entry.Id, x.Language.Code.Value, x.Entry.Lemma, x.Entry.PartOfSpeech, x.IsFavorite))
            .ToListAsync(ct);
        return new VocabularyPage(rows.Take(query.Limit).ToArray(), rows.Count > query.Limit ? query.Offset + query.Limit : null);
    }

    public async Task<VocabularyDetailDto?> FindAsync(Guid userId, Guid entryId, CancellationToken ct)
    {
        var word = await Words(userId).Where(x => x.Entry.Id == entryId)
            .Select(x => new VocabularyItemDto(x.Entry.Id, x.Language.Code.Value, x.Entry.Lemma, x.Entry.PartOfSpeech, x.IsFavorite))
            .SingleOrDefaultAsync(ct);
        if (word is null) return null;
        var senses = await VisibleSenses().Where(x => x.DictionaryEntryId == entryId)
            .OrderBy(x => x.SenseNumber).Select(sense => new VocabularySenseDto(sense.SenseNumber, sense.Definition,
                (from translation in db.Set<WordTranslation>()
                 join language in db.Languages on translation.TargetLanguageId equals language.Id
                 where translation.WordSenseId == sense.Id && language.IsActive
                 orderby language.Code, translation.Text
                 select new VocabularyTranslationDto(language.Code.Value, translation.Text)).ToList())).ToListAsync(ct);
        return new VocabularyDetailDto(word, senses);
    }

    public async Task<bool> SetFavoriteAsync(Guid userId, Guid entryId, bool isFavorite, CancellationToken ct)
    {
        if (!await Words(userId).AnyAsync(x => x.Entry.Id == entryId, ct)) return false;
        var id = Guid.NewGuid();
        var now = clock.GetUtcNow().UtcDateTime;
        await db.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO student_saved_words (id, student_id, dictionary_entry_id, saved_at_utc, is_favorite)
            VALUES ({id}, {userId}, {entryId}, {now}, {isFavorite})
            ON CONFLICT (student_id, dictionary_entry_id)
            DO UPDATE SET is_favorite = EXCLUDED.is_favorite
            """, ct);
        return true;
    }

    private IQueryable<WordRow> Words(Guid userId)
    {
        var visibleSenses = VisibleSenses();
        return from entry in db.Set<DictionaryEntry>().AsNoTracking()
            join language in db.Languages on entry.LanguageId equals language.Id
            where language.IsActive && (!db.Set<WordSense>().Any(sense => sense.DictionaryEntryId == entry.Id)
                || visibleSenses.Any(sense => sense.DictionaryEntryId == entry.Id))
            select new WordRow
            {
                Entry = entry, Language = language,
                IsFavorite = db.Set<StudentSavedWord>().Any(x => x.StudentId == userId
                    && x.DictionaryEntryId == entry.Id && x.IsFavorite)
            };
    }

    private IQueryable<WordSense> VisibleSenses()
    {
        var senses = db.Set<WordSense>().AsNoTracking();
        if (db.IncludeLegacyContent) return senses;

        // Match the old startup fixture's explicit marker and its complete word/translation signature.
        // Other senses on the same entry remain available. Keep all rows and their saved-word links.
        var arabic = LanguageCode.Create("ar");
        var turkish = LanguageCode.Create("tr");
        return senses.Where(sense => !(sense.SenseNumber == 1 && sense.Definition == "[DEV] A greeting."
            && db.Set<DictionaryEntry>().Any(entry => entry.Id == sense.DictionaryEntryId && entry.Lemma == "مرحبا"
                && entry.NormalizedLemma == "مرحبا" && entry.PartOfSpeech == "Interjection"
                && db.Languages.Any(language => language.Id == entry.LanguageId && language.Code == arabic))
            && db.Set<WordTranslation>().Count(translation => translation.WordSenseId == sense.Id) == 1
            && db.Set<WordTranslation>().Any(translation => translation.WordSenseId == sense.Id && translation.Text == "Merhaba"
                && db.Languages.Any(language => language.Id == translation.TargetLanguageId && language.Code == turkish))));
    }

    private sealed class WordRow
    {
        public required DictionaryEntry Entry { get; init; }
        public required Language Language { get; init; }
        public bool IsFavorite { get; init; }
    }
}
