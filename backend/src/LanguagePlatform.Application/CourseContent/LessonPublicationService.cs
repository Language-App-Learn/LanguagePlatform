using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Application.CourseContent;

public interface ILessonPublicationStore
{
    Task<LessonVersion?> FindAsync(Guid versionId, CancellationToken cancellationToken);
    Task<IReadOnlyList<LessonStage>> StagesAsync(Guid versionId, CancellationToken cancellationToken);
    Task SavePublicationAsync(LessonVersion version, Guid actorId, CancellationToken cancellationToken);
    Task WithdrawAsync(Guid versionId, Guid actorId, string reason, CancellationToken cancellationToken);
}

public sealed class LessonPublicationService(ILessonPublicationStore store, ICurrentActor actor)
{
    public Task WithdrawAsync(Guid versionId, string reason, CancellationToken cancellationToken)
    {
        if (actor.UserId is not { } actorId || !actor.HasPermission(Permissions.ContentPublish))
            throw new PermissionDeniedException();
        reason = Guard.Text(reason, 2000, nameof(reason));
        Guard.Against(reason.Contains('\0'), "Invalid withdrawal reason.");
        return store.WithdrawAsync(versionId, actorId, reason, cancellationToken);
    }

    public async Task PublishAsync(Guid versionId, uint expectedVersion, CancellationToken cancellationToken)
    {
        if (actor.UserId is not { } actorId || !actor.HasPermission(Permissions.ContentPublish))
            throw new PermissionDeniedException();
        Guard.Against(versionId == Guid.Empty, "Lesson version is required.");
        var version = await store.FindAsync(versionId, cancellationToken)
            ?? throw new ResourceNotFoundException();
        if (version.Version != expectedVersion)
            throw new StateConflictException("The lesson version has changed; reload before publishing.");
        var stages = await store.StagesAsync(versionId, cancellationToken);
        version.Publish(stages, DateTime.UtcNow);
        await store.SavePublicationAsync(version, actorId, cancellationToken);
    }
}
