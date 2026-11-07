using System.Text.Json;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Platform;
using Microsoft.EntityFrameworkCore;
using LanguagePlatform.Domain.Common;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Assessment;
using LanguagePlatform.Infrastructure.CourseContent;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class LessonPublicationStore(LanguagePlatformDbContext db) : ILessonPublicationStore
{
    public Task<LessonVersion?> FindAsync(Guid versionId, CancellationToken cancellationToken) =>
        db.Set<LessonVersion>().SingleOrDefaultAsync(x => x.Id == versionId, cancellationToken);

    public async Task<IReadOnlyList<LessonStage>> StagesAsync(Guid versionId, CancellationToken cancellationToken) =>
        await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == versionId).ToListAsync(cancellationToken);

    public async Task SavePublicationAsync(LessonVersion version, Guid actorId, CancellationToken cancellationToken)
    {
        if (version.UsesFiveStageCurriculum)
            await ValidateCurriculumContentAsync(version.Id, cancellationToken);
        var now = DateTime.UtcNow;
        var correlation = Guid.NewGuid().ToString("N");
        db.Set<ContentPublication>().Add(new ContentPublication
        {
            LessonVersionId = version.Id, PublishedBy = actorId, PublishedAtUtc = now
        });
        db.Set<OutboxMessage>().Add(new OutboxMessage
        {
            EventType = "LessonPublished", SchemaVersion = 1,
            PayloadJson = JsonSerializer.Serialize(new { LessonVersionId = version.Id }),
            OccurredAtUtc = now, AvailableAtUtc = now, AttemptCount = 0, CorrelationId = correlation
        });
        db.Set<AuditLog>().Add(new AuditLog
        {
            ActorId = actorId, Action = "content.publish", EntityType = "LessonVersion", EntityId = version.Id,
            OccurredAtUtc = now, CorrelationId = correlation, RedactedChangesJson = "{}"
        });
        // A single SaveChanges is atomic: publication, audit, outbox and xmin update commit together.
        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task ValidateCurriculumContentAsync(Guid versionId, CancellationToken ct)
    {
        Guard.Against(!await db.Set<AuditLog>().AnyAsync(x => x.EntityId == versionId && x.EntityType == nameof(LessonVersion) &&
            x.Action == "content.curriculum.review", ct), "Submit this version for teacher review first.");
        var stages = await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == versionId).ToListAsync(ct);
        var stageIds = stages.Select(x => x.Id).ToArray();
        var arabic = LanguageCode.Create("ar");
        var arabicTextStages = await (from text in db.Set<LessonStageContent>()
            join language in db.Languages on text.LanguageId equals language.Id
            where stageIds.Contains(text.LessonStageId) && language.Code == arabic && text.Body != null && text.Body != ""
            select text.LessonStageId).ToListAsync(ct);
        var assessments = await db.Set<AssessmentEntity>().Where(x => stageIds.Contains(x.LessonStageId)).ToListAsync(ct);
        var assessmentIds = assessments.Select(x => x.Id).ToArray();
        var questions = await (from link in db.Set<AssessmentQuestion>().AsNoTracking()
            join question in db.Set<Question>() on link.QuestionId equals question.Id
            where assessmentIds.Contains(link.AssessmentId)
            select new { link.AssessmentId, Question = question }).ToListAsync(ct);
        var questionIds = questions.Select(x => x.Question.Id).ToArray();
        var options = (await db.Set<QuestionOption>().AsNoTracking().Where(x => questionIds.Contains(x.QuestionId))
            .OrderBy(x => x.DisplayOrder).ToListAsync(ct)).ToLookup(x => x.QuestionId);
        var byAssessment = questions.ToLookup(x => x.AssessmentId, x => x.Question);
        var source = await db.Set<ReadingMaterial>().Where(x => x.LessonVersionId == versionId && x.OriginalPdf != null)
            .Select(x => new { x.Id, x.ReviewedAtUtc }).SingleOrDefaultAsync(ct);
        var reviewedPdf = source is not null && source.ReviewedAtUtc != null && await (
            from passage in db.Set<ReadingPassage>()
            join segment in db.Set<ReadingTextSegment>() on passage.Id equals segment.ReadingPassageId
            where passage.ReadingMaterialId == source.Id
            select segment.Id).AnyAsync(ct);
        Guard.Against(source is not null && !reviewedPdf, "Review the uploaded PDF and approve its Arabic reading lines.");

        foreach (var stage in stages.OrderBy(x => x.DisplayOrder))
        {
            var settings = CurriculumStageSettings.Read(stage.SettingsJson);
            if (stage.StageType == "reading")
                Guard.Against(!arabicTextStages.Contains(stage.Id) && !reviewedPdf, "Reading needs reviewed Arabic text.");
            if (stage.StageType == "speaking")
                Guard.Against(!arabicTextStages.Contains(stage.Id) || string.IsNullOrWhiteSpace(settings.EvaluationRubric),
                    "Speaking needs an Arabic prompt and a teacher evaluation rubric.");
            if (stage.StageType == "listening")
                Guard.Against(string.IsNullOrWhiteSpace(settings.AudioUrl), "Listening needs teacher-provided audio.");
            var matches = assessments.Where(x => x.LessonStageId == stage.Id).ToArray();
            Guard.Against(matches.Length != 1, $"The {stage.StageType} stage needs exactly one assessment.");
            var assessment = matches[0];
            var stageQuestions = byAssessment[assessment.Id].ToArray();
            Guard.Against(assessment.PassingScore != 0 || assessment.MaximumAttempts != stage.MaximumAttempts,
                "The assessment must use the lesson's stage attempt limit and no stage passing minimum.");
            Guard.Against(stage.StageType switch
            {
                "reading" => stageQuestions.Length != 10,
                "speaking" => stageQuestions.Length != 0,
                _ => stageQuestions.Length is < 1 or > 100
            }, stage.StageType == "reading" ? "Reading needs exactly ten comprehension questions."
                : $"The {stage.StageType} assessment has an invalid number of questions.");
            foreach (var question in stageQuestions)
            {
                Guard.Against(!ExerciseQuestions.Supports(stage.StageType, question.QuestionType),
                    "The assessment contains a question type unsupported for its stage.");
                ExerciseQuestions.ValidateStored(question, options[question.Id].ToArray());
            }
            assessment.Publish();
        }
    }
}
