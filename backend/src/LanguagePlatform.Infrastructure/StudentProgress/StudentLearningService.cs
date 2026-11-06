using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
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
        Guard.Against(!await IsCurriculumSlotUnlockedAsync(enrollment.Id, courseId, lessonId, ct),
            "The previous curriculum lesson has not been passed.");
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

    public async Task<CurriculumProgressDto?> GetCurriculumProgressAsync(Guid studentId, Guid courseId, Guid lessonId,
        CancellationToken ct)
    {
        var enrollment = await FindEnrollmentAsync(studentId, courseId, ct);
        if (enrollment is null) return null;
        var versionId = await content.FindVersionIdAsync(courseId, lessonId, ct);
        if (versionId is not { } publishedVersionId ||
            !await db.Set<LessonVersion>().AnyAsync(x => x.Id == publishedVersionId && x.UsesFiveStageCurriculum, ct))
            return null;

        var progress = await db.Set<LessonProgress>().AsNoTracking()
            .Where(x => x.EnrollmentId == enrollment.Id && x.LessonVersionId == versionId)
            .Select(x => new
            {
                x.Score, x.IsPassed,
                Stages = db.Set<StageProgress>().Where(stage => stage.LessonProgressId == x.Id)
                    .Select(stage => new
                    {
                        stage.LessonStageId, stage.IsCompleted, stage.Score,
                        Attempts = db.Set<StageAttempt>().Count(a => a.StageProgressId == stage.Id)
                    }).ToList()
            }).SingleOrDefaultAsync(ct);
        var stages = await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == versionId && x.IsActive)
            .OrderBy(x => x.DisplayOrder).ToListAsync(ct);
        var stageProgress = progress?.Stages.ToDictionary(x => x.LessonStageId);

        var available = enrollment.Status == "Active"
            && await IsCurriculumSlotUnlockedAsync(enrollment.Id, courseId, lessonId, ct);
        var states = new List<StageStateDto>(stages.Count);
        foreach (var stage in stages)
        {
            var state = stageProgress?.GetValueOrDefault(stage.Id);
            var complete = state?.IsCompleted == true;
            states.Add(new StageStateDto(stage.Id, stage.StageType, stage.DisplayOrder,
                complete ? "completed" : available ? "available" : "locked",
                complete ? state!.Score : null, state?.Attempts ?? 0));
            available &= complete;
        }

        var final = states.Count == FiveStageCurriculum.Stages.Count && states.All(x => x.Status == "completed");
        var passed = final && progress?.IsPassed == true;
        Guid? nextLessonId = null;
        if (passed)
        {
            var slot = await FindSlotAsync(courseId, lessonId, ct);
            if (slot is not null)
            {
                var next = await Slots(courseId).Where(x => x.Ordinal == slot.Ordinal + 1)
                    .Select(x => (Guid?)x.LessonId).SingleOrDefaultAsync(ct);
                if (next is { } nextId && await content.FindVersionIdAsync(courseId, nextId, ct) is not null)
                    nextLessonId = nextId;
            }
        }

        return new CurriculumProgressDto(publishedVersionId, states, final ? progress?.Score : null,
            FiveStageCurriculum.PassingScore, passed, nextLessonId);
    }

    private async Task<bool> IsCurriculumSlotUnlockedAsync(Guid enrollmentId, Guid courseId, Guid lessonId,
        CancellationToken ct)
    {
        var slot = await FindSlotAsync(courseId, lessonId, ct);
        if (slot is null || slot.Ordinal == 1) return true;
        return await Slots(courseId).Where(x => x.Ordinal == slot.Ordinal - 1)
            .AnyAsync(x => Progress(enrollmentId).Any(p => p.LessonId == x.LessonId && p.IsPassed), ct);
    }

    private Task<CurriculumSlot?> FindSlotAsync(Guid courseId, Guid lessonId, CancellationToken ct) =>
        Slots(courseId).SingleOrDefaultAsync(x => x.LessonId == lessonId, ct);

    private IQueryable<CurriculumSlot> Slots(Guid courseId) =>
        from level in db.Set<CourseLevel>()
        where level.CourseId == courseId
        join lesson in db.Set<Lesson>() on (Guid?)level.Id equals lesson.CurriculumLevelId
        where lesson.CurriculumPosition != null
        select new CurriculumSlot
        {
            LessonId = lesson.Id,
            Ordinal = (level.DisplayOrder - 1) * FiveStageCurriculum.SlotsPerLevel + lesson.CurriculumPosition!.Value
        };

    private sealed class CurriculumSlot
    {
        public Guid LessonId { get; init; }
        public int Ordinal { get; init; }
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
            Score = !version.UsesFiveStageCurriculum || db.Set<StageProgress>().Count(stage =>
                stage.LessonProgressId == progress.Id && stage.IsCompleted) == FiveStageCurriculum.Stages.Count
                ? progress.Score : null,
            IsPassed = progress.IsPassed, UpdatedAtUtc = progress.UpdatedAtUtc
        };

    private sealed class ProgressRow
    {
        public Guid LessonId { get; init; }
        public Guid LessonVersionId { get; init; }
        public decimal? Score { get; init; }
        public bool IsPassed { get; init; }
        public DateTime UpdatedAtUtc { get; init; }
    }
}
