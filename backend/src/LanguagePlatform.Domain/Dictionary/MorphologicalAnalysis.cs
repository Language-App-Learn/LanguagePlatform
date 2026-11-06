using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class MorphologicalAnalysis : PlatformEntity
{
    public required Guid WordFormId { get; init; }
    public required string AnalyzerVersion { get; init; }
    public required int FeaturesSchemaVersion { get; init; }
    public required string FeaturesJson { get; init; }
}

