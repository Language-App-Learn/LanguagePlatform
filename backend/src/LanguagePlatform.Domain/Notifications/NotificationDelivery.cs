using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Notifications;

public sealed class NotificationDelivery : PlatformEntity
{
    public required Guid NotificationId { get; init; }
    public required Guid DeviceRegistrationId { get; init; }
    public string? ProviderMessageId { get; init; }
    public required string Status { get; init; }
    public required int AttemptCount { get; init; }
    public DateTime? DeliveredAtUtc { get; init; }
}

