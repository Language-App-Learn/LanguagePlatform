using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserSession : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string TokenHash { get; init; }
    public required Guid FamilyId { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public DateTime? RevokedAtUtc { get; init; }
    public Guid? ReplacedBySessionId { get; init; }
    public string? DeviceName { get; init; }
    public uint Version { get; private set; }
}

