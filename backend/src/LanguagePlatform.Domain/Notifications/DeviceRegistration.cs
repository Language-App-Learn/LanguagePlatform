using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Notifications;

public sealed class DeviceRegistration : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string Platform { get; init; }
    public required string TokenHash { get; init; }
    public required string TokenCiphertext { get; init; }
    public required DateTime RegisteredAtUtc { get; init; }
    public required DateTime LastSeenAtUtc { get; init; }
    public DateTime? RevokedAtUtc { get; init; }
}

