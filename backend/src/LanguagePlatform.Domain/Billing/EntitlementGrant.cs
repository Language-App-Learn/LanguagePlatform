using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class EntitlementGrant : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required Guid EntitlementId { get; init; }
    public Guid? PurchaseId { get; init; }
    public Guid? GrantedBy { get; init; }
    public required DateTime StartsAtUtc { get; init; }
    public DateTime? EndsAtUtc { get; init; }
    public DateTime? RevokedAtUtc { get; init; }
    public required string IdempotencyKey { get; init; }
}

