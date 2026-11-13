using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public enum ReadingLineStatus
{
    Pending,
    Approved,
    RetryRequired,
    Inconclusive,
    TechnicalError
}

public sealed class ReadingLineAttempt : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid SegmentId { get; init; }
    public required Guid IdempotencyKey { get; init; }
    public required byte[] RecordingDigest { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime DeadlineUtc { get; init; }
    public ReadingLineStatus Status { get; init; }
    public string? Reason { get; init; }
}
