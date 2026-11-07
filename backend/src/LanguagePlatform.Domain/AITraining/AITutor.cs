using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AITutor : PlatformEntity
{
    public required string Code { get; init; }
    public required string Name { get; init; }
    public required Guid LanguageId { get; init; }
    public bool IsActive { get; init; }
}
