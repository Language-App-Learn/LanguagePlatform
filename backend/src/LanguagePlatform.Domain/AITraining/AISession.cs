using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AISession : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid PromptVersionId { get; init; }
    public required Guid ProviderConfigurationId { get; init; }
    public required DateTime StartedAtUtc { get; init; }
    public DateTime? EndedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public required string Status { get; init; }
    public uint Version { get; private set; }
}
