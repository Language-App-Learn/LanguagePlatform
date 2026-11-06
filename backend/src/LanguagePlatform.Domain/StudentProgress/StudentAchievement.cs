using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class StudentAchievement : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid AchievementId { get; init; }
    public required DateTime AwardedAtUtc { get; init; }
}

