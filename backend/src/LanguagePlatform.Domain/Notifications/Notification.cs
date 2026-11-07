using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Notifications;

public sealed class Notification : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required Guid TemplateId { get; init; }
    public required int PayloadSchemaVersion { get; init; }
    public required string PayloadJson { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public DateTime? ReadAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
}
