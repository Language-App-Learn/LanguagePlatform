using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class MediaVariant : PlatformEntity
{
    public required Guid MediaAssetId { get; init; }
    public required string VariantType { get; init; }
    public required string StorageKey { get; init; }
    public required string ContentType { get; init; }
    public required long FileSize { get; init; }
}
