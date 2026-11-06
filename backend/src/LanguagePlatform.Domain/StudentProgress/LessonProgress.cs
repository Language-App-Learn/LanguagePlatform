using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class LessonProgress : PlatformEntity
{
    public required Guid EnrollmentId { get; init; }
    public required Guid LessonVersionId { get; init; }
    public required decimal Score { get; init; }
    public bool IsPassed { get; init; }
    public required DateTime UpdatedAtUtc { get; init; }
    public uint Version { get; private set; }
}

