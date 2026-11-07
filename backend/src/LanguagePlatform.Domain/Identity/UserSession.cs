using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserSession : PlatformEntity
{
    public required Guid UserId { get; init; }
    public string TokenHash { get; private set; } = "";
    public required Guid FamilyId { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public DateTime? RevokedAtUtc { get; private set; }
    public Guid? ReplacedBySessionId { get; init; }
    public string? DeviceName { get; init; }
    public uint Version { get; private set; }

    public void Rotate(string tokenHash) => TokenHash = Guard.Text(tokenHash, 128, nameof(tokenHash));

    public void Revoke(DateTime utcNow) => RevokedAtUtc ??= utcNow;
}
