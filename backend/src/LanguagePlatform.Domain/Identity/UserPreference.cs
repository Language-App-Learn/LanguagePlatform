using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserPreference : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required Guid UiLanguageId { get; init; }
    public required int DailyGoalMinutes { get; init; }
    public bool NotificationsEnabled { get; init; }
}

