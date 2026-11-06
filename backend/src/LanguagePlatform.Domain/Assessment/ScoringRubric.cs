using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class ScoringRubric : PlatformEntity
{
    public required string Code { get; init; }
    public required int VersionNumber { get; init; }
    public required string CriteriaJson { get; init; }
    public required decimal MaximumScore { get; init; }
}

