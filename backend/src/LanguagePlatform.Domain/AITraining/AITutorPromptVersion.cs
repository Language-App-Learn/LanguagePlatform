using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AITutorPromptVersion : PlatformEntity
{
    public required Guid AITutorId { get; init; }
    public required int VersionNumber { get; init; }
    public required string SystemPrompt { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public DateTime? PublishedAtUtc { get; init; }
}
