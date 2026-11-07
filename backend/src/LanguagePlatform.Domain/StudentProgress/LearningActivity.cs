using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class LearningActivity : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public Guid? EnrollmentId { get; init; }
    public required string ActivityType { get; init; }
    public required DateTime OccurredAtUtc { get; init; }
    public required int DurationSeconds { get; init; }
}
