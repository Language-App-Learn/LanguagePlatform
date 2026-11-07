using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class Product : PlatformEntity
{
    public required string Code { get; init; }
    public required string Name { get; init; }
    public bool IsActive { get; init; }
}
