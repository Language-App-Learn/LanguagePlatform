using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.LessonEngine;

public sealed class LessonStage : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required string StageType { get; init; }
    public required int DisplayOrder { get; init; }
    public required decimal Weight { get; init; }
    public bool IsRequired { get; init; }
    public required decimal MinimumScore { get; init; }
    public required int MaximumAttempts { get; init; }
    public required int EstimatedDurationSeconds { get; init; }
    public required int SettingsSchemaVersion { get; init; }
    public required string SettingsJson { get; init; }
    public bool IsActive { get; init; }
}

