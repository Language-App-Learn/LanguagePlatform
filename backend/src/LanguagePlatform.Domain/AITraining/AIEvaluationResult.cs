using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.AITraining;

public sealed class AIEvaluationResult : PlatformEntity
{
    public required Guid AIEvaluationRequestId { get; init; }
    public required decimal PronunciationScore { get; init; }
    public required decimal FluencyScore { get; init; }
    public required decimal AccuracyScore { get; init; }
    public required decimal OverallScore { get; init; }
    public required string Feedback { get; init; }
    public required string ModelVersion { get; init; }
    public required DateTime EvaluatedAtUtc { get; init; }
    public bool AcceptedForScoring { get; init; }
    public Guid? ReviewedBy { get; init; }
}

