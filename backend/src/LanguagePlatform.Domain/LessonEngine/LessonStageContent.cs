using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.LessonEngine;

public sealed class LessonStageContent : PlatformEntity
{
    public required Guid LessonStageId { get; init; }
    public required Guid LanguageId { get; init; }
    public string? Body { get; init; }
    public Guid? MediaAssetId { get; init; }
}

