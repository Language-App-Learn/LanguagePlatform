using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Notifications;

public sealed class NotificationPreference : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string Category { get; init; }
    public bool PushEnabled { get; init; }
    public bool EmailEnabled { get; init; }
}
