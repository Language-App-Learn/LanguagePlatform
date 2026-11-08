using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class SecurityEvent : PlatformEntity
{
    public Guid? UserId { get; init; }
    public required string EventType { get; init; }
    public required DateTime OccurredAtUtc { get; init; }
    public required string CorrelationId { get; init; }
    public string? IpHash { get; init; }
}
