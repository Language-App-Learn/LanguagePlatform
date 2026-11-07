using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Platform;

public sealed class OutboxMessage : PlatformEntity
{
    public required string EventType { get; init; }
    public required int SchemaVersion { get; init; }
    public required string PayloadJson { get; init; }
    public required DateTime OccurredAtUtc { get; init; }
    public required DateTime AvailableAtUtc { get; init; }
    public DateTime? LeaseUntilUtc { get; init; }
    public DateTime? ProcessedAtUtc { get; init; }
    public required int AttemptCount { get; init; }
    public string? ErrorCode { get; init; }
    public required string CorrelationId { get; init; }
    public uint Version { get; private set; }
}
