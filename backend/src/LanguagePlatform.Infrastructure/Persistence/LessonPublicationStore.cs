using System.Text.Json;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Platform;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class LessonPublicationStore(LanguagePlatformDbContext db) : ILessonPublicationStore
{
    public Task<LessonVersion?> FindAsync(Guid versionId, CancellationToken cancellationToken) =>
        db.Set<LessonVersion>().SingleOrDefaultAsync(x => x.Id == versionId, cancellationToken);

    public async Task<IReadOnlyList<LessonStage>> StagesAsync(Guid versionId, CancellationToken cancellationToken) =>
        await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == versionId).ToListAsync(cancellationToken);

    public async Task SavePublicationAsync(LessonVersion version, Guid actorId, CancellationToken cancellationToken)
    {
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
}
