using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class MediaUsage : PlatformEntity
{
    public required Guid MediaAssetId { get; init; }
    public required string Purpose { get; init; }
    public required Guid UsedByUserId { get; init; }
    public required DateTime RecordedAtUtc { get; init; }
}
