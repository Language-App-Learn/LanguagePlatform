using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AIMessage : PlatformEntity
{
    public required Guid AISessionId { get; init; }
    public required int Sequence { get; init; }
    public required string Speaker { get; init; }
    public string? Text { get; init; }
    public Guid? AudioAssetId { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
}

