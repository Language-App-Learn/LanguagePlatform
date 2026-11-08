using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class SubscriptionPlan : PlatformEntity
{
    public required Guid ProductId { get; init; }
    public required string Code { get; init; }
    public required string Name { get; init; }
    public required int BillingPeriodMonths { get; init; }
    public bool IsActive { get; init; }
}
