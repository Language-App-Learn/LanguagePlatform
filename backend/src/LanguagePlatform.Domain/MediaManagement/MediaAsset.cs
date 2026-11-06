using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class MediaAsset : PlatformEntity
{
    public required string StorageKey { get; init; }
    public required string ContentType { get; init; }
    public required long FileSize { get; init; }
    public required string Checksum { get; init; }
    public required string OriginalFileName { get; init; }
    public required Guid UploadedBy { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required string Status { get; init; }
    public required Guid AccessPolicyId { get; init; }
    public string? License { get; init; }
    public string? RightsHolder { get; init; }
    public DateTime? RightsConfirmedAtUtc { get; init; }
    public DateTime? DeletedAtUtc { get; init; }
    public uint Version { get; private set; }
}

