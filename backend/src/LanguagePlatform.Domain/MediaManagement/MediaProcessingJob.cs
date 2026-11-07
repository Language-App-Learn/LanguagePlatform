using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class MediaProcessingJob : PlatformEntity
{
    public required Guid MediaAssetId { get; init; }
    public required string Operation { get; init; }
    public required string IdempotencyKey { get; init; }
    public required string Status { get; init; }
    public required int AttemptCount { get; init; }
    public required DateTime AvailableAtUtc { get; init; }
    public DateTime? LeaseUntilUtc { get; init; }
    public DateTime? CompletedAtUtc { get; init; }
    public string? ErrorCode { get; init; }
    public required string CorrelationId { get; init; }
    public uint Version { get; private set; }
}
