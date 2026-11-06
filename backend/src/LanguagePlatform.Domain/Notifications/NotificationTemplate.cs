using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Notifications;

public sealed class NotificationTemplate : PlatformEntity
{
    public required string Code { get; init; }
    public required Guid LanguageId { get; init; }
    public required string Title { get; init; }
    public required string Body { get; init; }
}

