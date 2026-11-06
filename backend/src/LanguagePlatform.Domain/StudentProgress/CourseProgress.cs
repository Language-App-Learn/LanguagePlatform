using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class CourseProgress : PlatformEntity
{
    public required Guid EnrollmentId { get; init; }
    public required int CompletedLessonCount { get; init; }
    public required DateTime UpdatedAtUtc { get; init; }
    public uint Version { get; private set; }
}

