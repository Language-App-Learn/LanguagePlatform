using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserConsent : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string Purpose { get; init; }
    public required string PolicyVersion { get; init; }
    public required DateTime GrantedAtUtc { get; init; }
    public DateTime? WithdrawnAtUtc { get; init; }
}

