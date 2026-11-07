using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Analytics;

public sealed class DailyCourseMetric : PlatformEntity
{
    public required Guid CourseId { get; init; }
    public required DateOnly MetricDate { get; init; }
    public required int ActiveStudents { get; init; }
    public required int LessonsCompleted { get; init; }
    public required int AssessmentsCompleted { get; init; }
    public required DateTime UpdatedAtUtc { get; init; }
}
