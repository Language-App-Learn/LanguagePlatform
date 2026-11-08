using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Dictionary;
using LanguagePlatform.Infrastructure.Identity;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class DevelopmentContentSeeder(LanguagePlatformDbContext db)
{
    public const string PublishedSlug = "dev-fixture-arabic-basics";
    public const string DraftSlug = "dev-fixture-unpublished";

    public async Task SeedAsync(CancellationToken cancellationToken)
    {
        await new CatalogDataSeeder(db).SeedAsync(cancellationToken);
        if (await db.Courses.AnyAsync(x => x.Slug == PublishedSlug, cancellationToken)) return;

        var tr = LanguageCode.Create("tr");
        var ar = LanguageCode.Create("ar");
        var path = await db.LearningPaths.SingleAsync(x => x.SourceLanguage.Code == tr && x.TargetLanguage.Code == ar, cancellationToken);
        var program = await db.LearningPrograms.SingleAsync(x => x.Code == "modern-language", cancellationToken);
        var course = Course.Create(path.Id, program.Id, PublishedSlug, "[DEV] Arabic basics", status: CourseStatus.Published);
        var draft = Course.Create(path.Id, program.Id, DraftSlug, "[DEV] Unpublished");
        var level = new CourseLevel { CourseId = course.Id, Code = "A1", DisplayOrder = 1 };
        var module = new CourseModule { CourseLevelId = level.Id, Title = "[DEV] Introduction", DisplayOrder = 1 };
        var unit = new CourseUnit { CourseModuleId = module.Id, Title = "[DEV] Greetings", DisplayOrder = 1 };
        var lesson = new Lesson { CourseUnitId = unit.Id, Slug = "greetings", DisplayOrder = 1 };
        var version = new LessonVersion { LessonId = lesson.Id, VersionNumber = 1, Title = "[DEV] Hello", PassingScore = 60 };
        var stage = new LessonStage
        {
            LessonVersionId = version.Id, StageType = "Assessment", DisplayOrder = 1, Weight = 100,
            IsActive = true, IsRequired = true, MinimumScore = 0, MaximumAttempts = 3,
            EstimatedDurationSeconds = 60, SettingsSchemaVersion = 1, SettingsJson = "{}"
        };
        version.SubmitForReview();
        version.Publish([stage], DateTime.UtcNow);
        db.AddRange(course, draft, level, module, unit, lesson, version, stage,
            new CourseLocalization { CourseId = course.Id, LanguageId = path.SourceLanguageId, Title = "[DEV] Arapça temelleri" },
            new LessonStageContent { LessonStageId = stage.Id, LanguageId = path.TargetLanguageId, Body = "مرحبا" });
        AddAssessment(stage, path.TargetLanguageId);
        var word = new DictionaryEntry
        {
            LanguageId = path.TargetLanguageId, Lemma = "مرحبا", NormalizedLemma = "مرحبا", PartOfSpeech = "Interjection"
        };
        var sense = new WordSense { DictionaryEntryId = word.Id, SenseNumber = 1, Definition = "[DEV] A greeting." };
        db.AddRange(word, sense, new WordTranslation { WordSenseId = sense.Id, TargetLanguageId = path.SourceLanguageId, Text = "Merhaba" });
        await db.SaveChangesAsync(cancellationToken);
    }

    private void AddAssessment(LessonStage stage, Guid languageId)
    {
        var assessment = new AssessmentEntity
        {
            LessonStageId = stage.Id, Title = "[DEV] Greetings quiz", PassingScore = 60,
            MaximumAttempts = 2, TimeLimitSeconds = 600
        };
        assessment.Publish();
        // The fixture author is an inactive ownership record with no credentials or roles.
        var email = $"dev-fixture-{Guid.NewGuid():N}@example.test";
        var author = new ApplicationUser
        {
            Id = Guid.NewGuid(), UserName = email, Email = email, IsActive = false,
            NormalizedUserName = email.ToUpperInvariant(), NormalizedEmail = email.ToUpperInvariant()
        };
        var bank = new QuestionBank { LanguageId = languageId, OwnerId = author.Id, Name = "[DEV] Greetings" };
        var choice = new Question
        {
            QuestionBankId = bank.Id, Code = "dev-greeting-choice", VersionNumber = 1, QuestionType = "MultipleChoice",
            Prompt = "Which means hello?", AnswerKeyJson = "{}"
        };
        var boolean = new Question
        {
            QuestionBankId = bank.Id, Code = "dev-greeting-boolean", VersionNumber = 1, QuestionType = "TrueFalse",
            Prompt = "مرحبا is a greeting.", AnswerKeyJson = "{\"correctAnswer\":true}"
        };
        db.AddRange(author, assessment, bank, choice, boolean,
            new QuestionOption { QuestionId = choice.Id, DisplayOrder = 1, Text = "مرحبا", IsCorrect = true },
            new QuestionOption { QuestionId = choice.Id, DisplayOrder = 2, Text = "كتاب" },
            new AssessmentQuestion { AssessmentId = assessment.Id, QuestionId = choice.Id, DisplayOrder = 1, MaximumScore = 1 },
            new AssessmentQuestion { AssessmentId = assessment.Id, QuestionId = boolean.Id, DisplayOrder = 2, MaximumScore = 1 });
    }
}
