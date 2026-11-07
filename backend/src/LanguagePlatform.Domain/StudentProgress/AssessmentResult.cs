using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class AssessmentResult : PlatformEntity
{
    public required Guid AssessmentAttemptId { get; init; }
    public required Guid StageAttemptId { get; init; }
    public required DateTime RecordedAtUtc { get; init; }
}
