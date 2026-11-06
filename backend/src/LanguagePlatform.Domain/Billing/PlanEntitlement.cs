using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class PlanEntitlement : PlatformEntity
{
    public required Guid SubscriptionPlanId { get; init; }
    public required Guid EntitlementId { get; init; }
    public int? UsageLimit { get; init; }
}

