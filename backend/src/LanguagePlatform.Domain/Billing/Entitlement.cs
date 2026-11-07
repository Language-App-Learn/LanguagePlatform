using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Billing;

public sealed class Entitlement : PlatformEntity
{
    public required string Code { get; init; }
    public required string Description { get; init; }
}
