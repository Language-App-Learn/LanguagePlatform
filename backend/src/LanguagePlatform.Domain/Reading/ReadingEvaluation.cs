using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingEvaluation : PlatformEntity
{
    public required Guid ReadingSessionId { get; init; }
    public required Guid AIEvaluationRequestId { get; init; }
}
