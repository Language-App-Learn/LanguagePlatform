using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class StudentAnswer : PlatformEntity
{
    public required Guid AttemptQuestionId { get; init; }
    public string? AnswerText { get; init; }
    public required string SelectedOptionsJson { get; init; }
    public required DateTime SubmittedAtUtc { get; init; }
}
