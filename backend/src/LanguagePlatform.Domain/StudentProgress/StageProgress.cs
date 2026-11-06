using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class StageProgress : PlatformEntity
{
    public required Guid LessonProgressId { get; init; }
    public required Guid LessonVersionId { get; init; }
    public required Guid LessonStageId { get; init; }
    public required decimal Score { get; init; }
    public bool IsCompleted { get; init; }
    public required DateTime UpdatedAtUtc { get; init; }
    public uint Version { get; private set; }
}

