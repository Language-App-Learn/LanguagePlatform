using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AIEvaluationRequest : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public Guid? StageAttemptId { get; init; }
    public required Guid AudioAssetId { get; init; }
    public required Guid ProviderConfigurationId { get; init; }
    public required Guid ScoringRubricId { get; init; }
    public required string ReferenceText { get; init; }
    public required string IdempotencyKey { get; init; }
    public required string Status { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public uint Version { get; private set; }
}
