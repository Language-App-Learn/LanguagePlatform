namespace LanguagePlatform.Application.StudentProgress;

public sealed record EnrollmentDto(Guid Id, Guid CourseId, string Status, DateTime EnrolledAtUtc);
public sealed record LessonProgressDto(Guid LessonId, Guid LessonVersionId, decimal Score, bool IsPassed, DateTime UpdatedAtUtc);
public sealed record CourseProgressDto(EnrollmentDto Enrollment, int CompletedLessons, LessonProgressDto? ContinueFrom);
public sealed record LessonProgressPage(IReadOnlyList<LessonProgressDto> Items, int? NextOffset);
