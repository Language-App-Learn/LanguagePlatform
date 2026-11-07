using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class Price : PlatformEntity
{
    public required Guid ProductId { get; init; }
    public required string Provider { get; init; }
    public required string ExternalPriceId { get; init; }
    public required decimal Amount { get; init; }
    public required string Currency { get; init; }
    public required DateTime ValidFromUtc { get; init; }
    public DateTime? ValidUntilUtc { get; init; }
}
