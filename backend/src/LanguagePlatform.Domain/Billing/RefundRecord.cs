using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class RefundRecord : PlatformEntity
{
    public required Guid PaymentTransactionId { get; init; }
    public required string Provider { get; init; }
    public required string ExternalRefundId { get; init; }
    public required decimal Amount { get; init; }
    public required string Currency { get; init; }
    public required string Reason { get; init; }
    public required DateTime RefundedAtUtc { get; init; }
}
