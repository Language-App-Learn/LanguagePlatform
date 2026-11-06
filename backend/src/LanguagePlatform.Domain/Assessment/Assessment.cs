using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class Assessment : PlatformEntity
{
    public required Guid LessonStageId { get; init; }
    public required string Title { get; init; }
    public required decimal PassingScore { get; init; }
    public required int MaximumAttempts { get; init; }
    public int? TimeLimitSeconds { get; init; }
    public bool IsPublished { get; init; }
}

