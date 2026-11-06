using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class LearningStreak : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required DateOnly ActivityDate { get; init; }
    public required int ActiveMinutes { get; init; }
}

