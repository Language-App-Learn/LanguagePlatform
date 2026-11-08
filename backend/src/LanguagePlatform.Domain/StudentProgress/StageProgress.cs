using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class StageProgress : PlatformEntity
{
    public required Guid LessonProgressId { get; init; }
    public required Guid LessonVersionId { get; init; }
    public required Guid LessonStageId { get; init; }
    public decimal Score { get; private set; }
    public bool IsCompleted { get; private set; }
    public DateTime UpdatedAtUtc { get; private set; } = DateTime.UtcNow;
    public uint Version { get; private set; }

    public void RecordScore(decimal score, DateTime nowUtc)
    {
        Score = Guard.Percentage(score);
        IsCompleted = true;
        UpdatedAtUtc = nowUtc;
    }
}
