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
        var stageIds = await db.Set<LessonStage>().Where(x => x.LessonVersionId == versionId)
            .Select(x => new { x.Id, x.StageType }).ToListAsync(ct);
        var readingId = stageIds.Single(x => x.StageType == "reading").Id;
        var arabic = LanguageCode.Create("ar");
        var approvedText = await (from text in db.Set<LessonStageContent>()
            join language in db.Languages on text.LanguageId equals language.Id
            where text.LessonStageId == readingId && language.Code == arabic && text.Body != null && text.Body != ""
            select text.Id).AnyAsync(ct);
        Guard.Against(!approvedText, "Reading needs approved Arabic text.");
        var reading = await db.Set<AssessmentEntity>().Where(x => x.LessonStageId == readingId)
            .Select(x => x.Id).SingleOrDefaultAsync(ct);
        var readingQuestionCount = await db.Set<AssessmentQuestion>().CountAsync(x => x.AssessmentId == reading, ct);
        Guard.Against(readingQuestionCount != 10, "Reading needs exactly ten comprehension questions.");

        // The current authoring endpoints cannot configure these stage workflows safely.
        // Do not expose a lesson that students cannot complete.
        throw new DomainException("Five-stage publication requires configured speaking evaluation, listening and writing exercises.");
    }
}
