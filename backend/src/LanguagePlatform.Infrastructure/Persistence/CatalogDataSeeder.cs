using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class CatalogDataSeeder(LanguagePlatformDbContext dbContext)
{
    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        var languages = await dbContext.Languages.ToListAsync(cancellationToken);
        AddLanguageIfMissing(languages, Language.Create("tr", "Turkish", "Türkçe", TextDirection.LeftToRight, id: CatalogSeedIds.Turkish));
        AddLanguageIfMissing(languages, Language.Create("ar", "Arabic", "العربية", TextDirection.RightToLeft, id: CatalogSeedIds.Arabic));
        AddLanguageIfMissing(languages, Language.Create("en", "English", "English", TextDirection.LeftToRight, id: CatalogSeedIds.English));
        await dbContext.SaveChangesAsync(cancellationToken);

        languages = await dbContext.Languages.ToListAsync(cancellationToken);
        var byCode = languages.ToDictionary(language => language.Code.Value, StringComparer.OrdinalIgnoreCase);

        var paths = await dbContext.LearningPaths.ToListAsync(cancellationToken);
        AddPathIfMissing(paths, LearningPath.Create(byCode["tr"], byCode["ar"], id: CatalogSeedIds.TurkishToArabic));
        AddPathIfMissing(paths, LearningPath.Create(byCode["en"], byCode["ar"], id: CatalogSeedIds.EnglishToArabic));
        AddPathIfMissing(paths, LearningPath.Create(byCode["ar"], byCode["tr"], id: CatalogSeedIds.ArabicToTurkish));

        var programs = await dbContext.LearningPrograms.ToListAsync(cancellationToken);
        AddProgramIfMissing(programs, LearningProgram.Create("modern-language", "Modern Language", ProgramType.ModernLanguage, id: CatalogSeedIds.ModernLanguage));
        AddProgramIfMissing(programs, LearningProgram.Create("ydt", "YDT", ProgramType.ExamPreparation, id: CatalogSeedIds.Ydt));
        AddProgramIfMissing(programs, LearningProgram.Create("yds", "YDS", ProgramType.ExamPreparation, id: CatalogSeedIds.Yds));
        AddProgramIfMissing(programs, LearningProgram.Create("yokdil", "YÖKDİL", ProgramType.ExamPreparation, id: CatalogSeedIds.Yokdil));
        AddProgramIfMissing(programs, LearningProgram.Create("quran-reading", "Quran Reading", ProgramType.ReligiousReading, id: CatalogSeedIds.QuranReading));

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private void AddLanguageIfMissing(IReadOnlyCollection<Language> existing, Language candidate)
    {
        if (!existing.Any(language => language.Code == candidate.Code))
        {
            dbContext.Languages.Add(candidate);
        }
    }

    private void AddPathIfMissing(IReadOnlyCollection<LearningPath> existing, LearningPath candidate)
    {
        if (!existing.Any(path => path.SourceLanguageId == candidate.SourceLanguageId && path.TargetLanguageId == candidate.TargetLanguageId))
        {
            dbContext.LearningPaths.Add(candidate);
        }
    }

    private void AddProgramIfMissing(IReadOnlyCollection<LearningProgram> existing, LearningProgram candidate)
    {
        if (!existing.Any(program => string.Equals(program.Code, candidate.Code, StringComparison.OrdinalIgnoreCase)))
        {
            dbContext.LearningPrograms.Add(candidate);
        }
    }
}
