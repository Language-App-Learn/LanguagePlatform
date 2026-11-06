using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.StudentProgress;

public sealed class StudentLearningService(LanguagePlatformDbContext db, IPublishedContentQueries content, TimeProvider clock)
{
    public async Task<EnrollmentDto?> EnrollAsync(Guid studentId, Guid courseId, CancellationToken ct)
    {
        var existing = await FindEnrollmentAsync(studentId, courseId, ct);
        if (existing is not null) return existing;
        if (!await db.PublishedCourses().AnyAsync(x => x.Id == courseId, ct)) return null;
        var blocked = await db.Set<CoursePrerequisite>().AnyAsync(x => x.CourseId == courseId &&
            !db.Set<Enrollment>().Any(e => e.StudentId == studentId && e.CourseId == x.RequiredCourseId
                && e.Status == "Completed"), ct);
        Guard.Against(blocked, "Course prerequisites have not been completed.");
        var id = Guid.NewGuid();
        var now = clock.GetUtcNow().UtcDateTime;
        await db.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO enrollments (id, student_id, course_id, enrolled_at_utc, status)
            VALUES ({id}, {studentId}, {courseId}, {now}, 'Active')
            ON CONFLICT (student_id, course_id) DO NOTHING
            """, ct);
        return await FindEnrollmentAsync(studentId, courseId, ct);
    }

    public async Task<CourseProgressDto?> GetCourseAsync(Guid studentId, Guid courseId, CancellationToken ct)
    {
        var enrollment = await FindEnrollmentAsync(studentId, courseId, ct);
        if (enrollment is null) return null;
        var rows = Progress(enrollment.Id);
        var completed = await rows.Where(x => x.IsPassed).Select(x => x.LessonId).Distinct().CountAsync(ct);
        var resume = await rows.OrderByDescending(x => x.UpdatedAtUtc).ThenByDescending(x => x.LessonVersionId)
            .Select(x => new LessonProgressDto(x.LessonId, x.LessonVersionId, x.Score, x.IsPassed, x.UpdatedAtUtc))
            .FirstOrDefaultAsync(ct);
        return new CourseProgressDto(enrollment, completed, resume);
    }

    public async Task<LessonProgressPage?> GetLessonsAsync(Guid studentId, Guid courseId, OutlineQuery query,
        bool completedOnly, CancellationToken ct)
    {
        query.Validate();
        var enrollment = await FindEnrollmentAsync(studentId, courseId, ct);
        if (enrollment is null) return null;
        var rows = await Progress(enrollment.Id).Where(x => !completedOnly || x.IsPassed)
            .OrderByDescending(x => x.UpdatedAtUtc).ThenByDescending(x => x.LessonVersionId)
            .Skip(query.Offset).Take(query.Limit + 1)
            .Select(x => new LessonProgressDto(x.LessonId, x.LessonVersionId, x.Score, x.IsPassed, x.UpdatedAtUtc))
            .ToListAsync(ct);
        return new LessonProgressPage(rows.Take(query.Limit).ToArray(),
            rows.Count > query.Limit ? query.Offset + query.Limit : null);
    }

    public async Task<LessonProgressDto?> StartAsync(Guid studentId, Guid courseId, Guid lessonId, CancellationToken ct)
    {
        var enrollment = await FindEnrollmentAsync(studentId, courseId, ct);
        if (enrollment?.Status != "Active") return null;
        var versionId = await content.FindVersionIdAsync(courseId, lessonId, ct);
        if (versionId is null) return null;
        var blocked = await db.Set<LessonPrerequisite>().AnyAsync(x => x.LessonId == lessonId &&
            !Progress(enrollment.Id).Any(p => p.LessonId == x.RequiredLessonId && p.IsPassed), ct);
        Guard.Against(blocked, "Lesson prerequisites have not been completed.");
        var id = Guid.NewGuid();
        var now = clock.GetUtcNow().UtcDateTime;
        // Only the request that creates progress records the start activity. Retrying never changes scores.
        await db.Database.ExecuteSqlInterpolatedAsync($"""
            WITH inserted AS (
                INSERT INTO lesson_progress (id, enrollment_id, lesson_version_id, score, is_passed, updated_at_utc)
                VALUES ({id}, {enrollment.Id}, {versionId.Value}, 0, false, {now})
                ON CONFLICT (enrollment_id, lesson_version_id) DO NOTHING
                RETURNING id
            )
            INSERT INTO learning_activities (id, student_id, enrollment_id, activity_type, occurred_at_utc, duration_seconds)
            SELECT {Guid.NewGuid()}, {studentId}, {enrollment.Id}, 'LessonStarted', {now}, 0 FROM inserted
            """, ct);
        return await Progress(enrollment.Id).Where(x => x.LessonVersionId == versionId)
            .Select(x => new LessonProgressDto(x.LessonId, x.LessonVersionId, x.Score, x.IsPassed, x.UpdatedAtUtc))
            .SingleAsync(ct);
    }

    private Task<EnrollmentDto?> FindEnrollmentAsync(Guid studentId, Guid courseId, CancellationToken ct) =>
        db.Set<Enrollment>().AsNoTracking().Where(x => x.StudentId == studentId && x.CourseId == courseId)
            .Select(x => new EnrollmentDto(x.Id, x.CourseId, x.Status, x.EnrolledAtUtc)).SingleOrDefaultAsync(ct);

    private IQueryable<ProgressRow> Progress(Guid enrollmentId) =>
        from progress in db.Set<LessonProgress>().AsNoTracking()
        where progress.EnrollmentId == enrollmentId
        join version in db.Set<LessonVersion>() on progress.LessonVersionId equals version.Id
        select new ProgressRow
        {
            LessonId = version.LessonId, LessonVersionId = version.Id,
            Score = progress.Score, IsPassed = progress.IsPassed, UpdatedAtUtc = progress.UpdatedAtUtc
        };

    private sealed class ProgressRow
    {
        public Guid LessonId { get; init; }
        public Guid LessonVersionId { get; init; }
        public decimal Score { get; init; }
        public bool IsPassed { get; init; }
        public DateTime UpdatedAtUtc { get; init; }
    }
}
