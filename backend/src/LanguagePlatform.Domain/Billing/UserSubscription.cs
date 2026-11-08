using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class UserSubscription : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required Guid SubscriptionPlanId { get; init; }
    public required string Provider { get; init; }
    public required string ExternalSubscriptionId { get; init; }
    public required string Status { get; init; }
    public required DateTime StartsAtUtc { get; init; }
    public required DateTime EndsAtUtc { get; init; }
    public DateTime? CancelledAtUtc { get; init; }
    public uint Version { get; private set; }
}
