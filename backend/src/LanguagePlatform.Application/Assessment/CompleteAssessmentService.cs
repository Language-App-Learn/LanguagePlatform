using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Application.Assessment;

public interface IAssessmentCompletionStore
{
    Task<AssessmentAttempt?> FindAsync(Guid id, CancellationToken cancellationToken);
    Task<decimal?> GetFullyEvaluatedScoreAsync(Guid attemptId, CancellationToken cancellationToken);
    Task SaveAsync(CancellationToken cancellationToken);
}

public sealed class CompleteAssessmentService(IAssessmentCompletionStore store, ICurrentActor actor)
{
    public async Task CompleteAsync(Guid attemptId, CancellationToken cancellationToken)
    {
        if (!actor.HasPermission(Permissions.AssessmentEvaluate)) throw new PermissionDeniedException();
        var attempt = await store.FindAsync(attemptId, cancellationToken)
            ?? throw new DomainException("Assessment attempt not found.");
        var score = await store.GetFullyEvaluatedScoreAsync(attemptId, cancellationToken)
            ?? throw new DomainException("All answers must be evaluated before completion.");
        attempt.Complete(score, DateTime.UtcNow);
        await store.SaveAsync(cancellationToken);
    }
}
