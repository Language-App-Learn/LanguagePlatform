using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AIProviderConfiguration : PlatformEntity
{
    public required string Code { get; init; }
    public required string Model { get; init; }
    public required string Capability { get; init; }
    public required string SecretReference { get; init; }
    public bool IsEnabled { get; init; }
}
