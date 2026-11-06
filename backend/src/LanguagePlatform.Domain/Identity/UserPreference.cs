using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Identity;

public sealed class UserPreference : PlatformEntity
{
    public required Guid UserId { get; init; }
    public Guid UiLanguageId { get; private set; }
    public Guid? LearningPathId { get; private set; }
    public int DailyGoalMinutes { get; private set; }
    public bool NotificationsEnabled { get; private set; }
    public uint Version { get; private set; }

    public void Update(Guid uiLanguageId, Guid? learningPathId, int dailyGoalMinutes, bool notificationsEnabled)
    {
        Guard.Against(uiLanguageId == Guid.Empty || learningPathId == Guid.Empty, "Invalid language selection.");
        Guard.Against(dailyGoalMinutes is < 1 or > 1440, "Daily goal must be between 1 and 1440 minutes.");
        UiLanguageId = uiLanguageId;
        LearningPathId = learningPathId;
        DailyGoalMinutes = dailyGoalMinutes;
        NotificationsEnabled = notificationsEnabled;
    }
}

