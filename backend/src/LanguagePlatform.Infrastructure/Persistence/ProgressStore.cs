using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.StudentProgress;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class ProgressStore(LanguagePlatformDbContext db) : IProgressStore
{
    public async Task<ProgressInput?> ReadAsync(Guid lessonProgressId, CancellationToken cancellationToken)
    {
        // Track progress to retain its original xmin until the aggregate update is saved.
        var progress = await db.Set<LessonProgress>().SingleOrDefaultAsync(x => x.Id == lessonProgressId, cancellationToken);
        if (progress == null) return null;
        var studentId = await db.Set<Enrollment>().Where(x => x.Id == progress.EnrollmentId).Select(x => x.StudentId).SingleAsync(cancellationToken);
        var version = await db.Set<LessonVersion>().SingleAsync(x => x.Id == progress.LessonVersionId, cancellationToken);
        var stages = await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == version.Id).ToListAsync(cancellationToken);
        var attempts = await (from attempt in db.Set<StageAttempt>()
            join stage in db.Set<StageProgress>() on attempt.StageProgressId equals stage.Id
            where stage.LessonProgressId == lessonProgressId
            select new StageScore(stage.LessonStageId, attempt.AttemptNumber, attempt.Score, attempt.Status == AttemptStatus.Completed))
            .ToListAsync(cancellationToken);
        return new ProgressInput(studentId, version, stages, attempts);
    }

    public async Task SaveAsync(Guid lessonProgressId, LessonScore result, CancellationToken cancellationToken)
    {
        var progress = db.Set<LessonProgress>().Local.Single(x => x.Id == lessonProgressId);
        progress.RecordScore(result.Score, result.Passed, DateTime.UtcNow);
        await db.SaveChangesAsync(cancellationToken);
    }
}
