using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class AssessmentQuestion : PlatformEntity
{
    public required Guid AssessmentId { get; init; }
    public required Guid QuestionId { get; init; }
    public required int DisplayOrder { get; init; }
    public required decimal MaximumScore { get; init; }
}
