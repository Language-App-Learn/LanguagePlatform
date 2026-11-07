using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserProfile : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string DisplayName { get; init; }
    public string? Biography { get; init; }
    public required string TimeZone { get; init; }
}
