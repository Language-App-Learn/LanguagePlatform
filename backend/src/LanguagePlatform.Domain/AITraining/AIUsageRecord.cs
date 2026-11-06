using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AIUsageRecord : PlatformEntity
{
    public required Guid ProviderConfigurationId { get; init; }
    public required Guid StudentId { get; init; }
    public Guid? AISessionId { get; init; }
    public Guid? EvaluationRequestId { get; init; }
    public required string ProviderRequestId { get; init; }
    public required long InputUnits { get; init; }
    public required long OutputUnits { get; init; }
    public required decimal Cost { get; init; }
    public required string Currency { get; init; }
    public required DateTime RecordedAtUtc { get; init; }
}

