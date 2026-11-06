using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class AnswerEvaluation : PlatformEntity
{
    public required Guid StudentAnswerId { get; init; }
    public required Guid ScoringRubricId { get; init; }
    public Guid? EvaluatorId { get; init; }
    public required decimal Score { get; init; }
    public string? Feedback { get; init; }
    public required DateTime EvaluatedAtUtc { get; init; }
    public required string Method { get; init; }
}

