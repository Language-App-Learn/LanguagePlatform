using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.LessonEngine;

public sealed class StageDependency : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required Guid StageId { get; init; }
    public required Guid RequiredStageId { get; init; }
}

