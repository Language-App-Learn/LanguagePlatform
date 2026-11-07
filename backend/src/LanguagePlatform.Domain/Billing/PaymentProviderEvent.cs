using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class PaymentProviderEvent : PlatformEntity
{
    public required string Provider { get; init; }
    public required string ExternalEventId { get; init; }
    public required string EventType { get; init; }
    public required string PayloadHash { get; init; }
    public required DateTime ReceivedAtUtc { get; init; }
    public DateTime? VerifiedAtUtc { get; init; }
    public DateTime? ProcessedAtUtc { get; init; }
    public required int AttemptCount { get; init; }
    public string? ErrorCode { get; init; }
    public uint Version { get; private set; }
}
