using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class PaymentTransaction : PlatformEntity
{
    public required Guid PurchaseId { get; init; }
    public required string Provider { get; init; }
    public required string ExternalTransactionId { get; init; }
    public required decimal Amount { get; init; }
    public required string Currency { get; init; }
    public required string Status { get; init; }
    public required DateTime OccurredAtUtc { get; init; }
}
