using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class AssessmentAttempt : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid AssessmentId { get; init; }
    public DateTime StartedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime? CompletedAtUtc { get; private set; }
    public decimal? Score { get; private set; }
    public required decimal MaximumScore { get; init; }
    public AttemptStatus Status { get; private set; } = AttemptStatus.InProgress;
    public required int AttemptNumber { get; init; }
    public required string IdempotencyKey { get; init; }
    public uint Version { get; private set; }

    public void Submit()
    {
        Guard.Against(Status != AttemptStatus.InProgress, "This attempt has already been submitted.");
        Guard.Against(MaximumScore <= 0 || AttemptNumber < 1, "Invalid attempt configuration.");
        Status = AttemptStatus.PendingEvaluation;
    }

    public void Complete(decimal score, DateTime nowUtc)
    {
        Guard.Against(Status != AttemptStatus.PendingEvaluation, "Only submitted attempts can be evaluated.");
        Guard.Against(score < 0 || score > MaximumScore, "Score exceeds the assessment range.");
        Guard.Against(nowUtc.Kind != DateTimeKind.Utc || nowUtc < StartedAtUtc, "Invalid completion time.");
        Score = score;
        CompletedAtUtc = nowUtc;
        Status = AttemptStatus.Completed;
    }
}
