using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingSession : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid ReadingMaterialId { get; init; }
    public required DateTime StartedAtUtc { get; init; }
    public DateTime? CompletedAtUtc { get; init; }
    public Guid? AudioAssetId { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
}

