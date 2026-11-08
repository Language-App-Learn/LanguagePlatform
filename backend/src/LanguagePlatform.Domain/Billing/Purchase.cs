using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class Purchase : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required Guid PriceId { get; init; }
    public required string Provider { get; init; }
    public required string ExternalPurchaseId { get; init; }
    public required decimal Amount { get; init; }
    public required string Currency { get; init; }
    public required DateTime PurchasedAtUtc { get; init; }
    public DateTime? VerifiedAtUtc { get; init; }
}
