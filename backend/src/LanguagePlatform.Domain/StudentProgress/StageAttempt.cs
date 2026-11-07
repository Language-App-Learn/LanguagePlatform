using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class StageAttempt : PlatformEntity
{
    public required Guid StageProgressId { get; init; }
    public required int AttemptNumber { get; init; }
    public required AttemptStatus Status { get; init; }
    public decimal? Score { get; init; }
    public required DateTime StartedAtUtc { get; init; }
    public DateTime? CompletedAtUtc { get; init; }
    public required string IdempotencyKey { get; init; }
    public uint Version { get; private set; }
}
