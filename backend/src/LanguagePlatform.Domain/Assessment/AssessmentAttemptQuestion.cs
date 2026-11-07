using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class AssessmentAttemptQuestion : PlatformEntity
{
    public required Guid AssessmentAttemptId { get; init; }
    public required Guid QuestionId { get; init; }
    public required int DisplayOrder { get; init; }
    public required string PromptSnapshot { get; init; }
    public required string AnswerKeySnapshotJson { get; init; }
    public required string OptionsSnapshotJson { get; init; }
    public required decimal MaximumScore { get; init; }
}
