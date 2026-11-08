using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class Achievement : PlatformEntity
{
    public required string Code { get; init; }
    public required string Name { get; init; }
    public required string Description { get; init; }
}
