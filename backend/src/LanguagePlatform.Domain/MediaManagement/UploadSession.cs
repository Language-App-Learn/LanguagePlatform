using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class UploadSession : PlatformEntity
{
    public required Guid UserId { get; init; }
    public Guid? MediaAssetId { get; init; }
    public required string StorageKey { get; init; }
    public required long MaximumBytes { get; init; }
    public required string ExpectedContentType { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public DateTime? CompletedAtUtc { get; init; }
}
