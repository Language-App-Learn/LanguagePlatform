using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class LessonProgress : PlatformEntity
{
    public required Guid EnrollmentId { get; init; }
    public required Guid LessonVersionId { get; init; }
    public decimal Score { get; private set; }
    public bool IsPassed { get; private set; }
    public DateTime UpdatedAtUtc { get; private set; } = DateTime.UtcNow;
    public uint Version { get; private set; }

    public void RecordScore(decimal score, bool passed, DateTime nowUtc)
    {
        Score = Guard.Percentage(score);
        IsPassed = passed;
        UpdatedAtUtc = nowUtc;
    }
}
