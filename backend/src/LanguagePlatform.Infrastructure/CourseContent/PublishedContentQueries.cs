using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class PublishedContentQueries(LanguagePlatformDbContext db) : IPublishedContentQueries
{
    public async Task<LessonOutlinePage?> ListAsync(Guid courseId, OutlineQuery query, CancellationToken cancellationToken)
    {
        query.Validate();
        if (!await db.PublishedCourses().AnyAsync(x => x.Id == courseId, cancellationToken)) return null;
        var rows = await VisibleLessons(courseId)
            .OrderBy(x => x.Level.DisplayOrder).ThenBy(x => x.Module.DisplayOrder)
            .ThenBy(x => x.Unit.DisplayOrder).ThenBy(x => x.Lesson.DisplayOrder).ThenBy(x => x.Lesson.Id)
            .Skip(query.Offset).Take(query.Limit + 1)
            .Select(x => new LessonOutlineDto(x.Lesson.Id, x.Version.Id, x.Version.VersionNumber, x.Version.Title,
                x.Level.Id, x.Level.Code, x.Module.Id, x.Module.Title, x.Unit.Id, x.Unit.Title, x.Lesson.DisplayOrder))
            .ToListAsync(cancellationToken);
        return new LessonOutlinePage(rows.Take(query.Limit).ToArray(),
            rows.Count > query.Limit ? query.Offset + query.Limit : null);
    }

    public async Task<PublishedLessonDto?> FindAsync(Guid courseId, Guid lessonId, CancellationToken cancellationToken)
    {
        var lesson = await VisibleLessons(courseId).Where(x => x.Lesson.Id == lessonId)
            .Select(x => new { x.Version.Id, x.Version.VersionNumber, x.Version.Title, x.Version.PassingScore,
                x.Lesson.DisplayOrder, Target = x.Course.LearningPath.TargetLanguage.Code })
            .SingleOrDefaultAsync(cancellationToken);
        if (lesson is null) return null;

        var translations = await (from entry in db.Set<LessonLocalization>().AsNoTracking()
            join language in db.Languages on entry.LanguageId equals language.Id
            where entry.LessonVersionId == lesson.Id && language.IsActive
            orderby language.Code
            select new LessonTranslationDto(language.Code.Value, entry.Title, entry.Description))
            .ToListAsync(cancellationToken);
        var stages = await db.Set<LessonStage>().AsNoTracking()
            .Where(x => x.LessonVersionId == lesson.Id && x.IsActive).OrderBy(x => x.DisplayOrder)
            .Select(stage => new StageDto(stage.Id, stage.StageType, stage.DisplayOrder, stage.IsRequired,
                stage.Weight, stage.MinimumScore, stage.MaximumAttempts, stage.EstimatedDurationSeconds,
                (from content in db.Set<LessonStageContent>()
                 join language in db.Languages on content.LanguageId equals language.Id
                 where content.LessonStageId == stage.Id && content.Body != null && language.IsActive
                 orderby language.Code
                 select new StageTextDto(language.Code.Value, content.Body!)).ToList(),
                db.Set<AssessmentEntity>().Where(a => a.LessonStageId == stage.Id && a.IsPublished)
                    .Select(a => (Guid?)a.Id).FirstOrDefault()))
            .ToListAsync(cancellationToken);
        return new PublishedLessonDto(lessonId, courseId, lesson.Id, lesson.VersionNumber, lesson.Title,
            lesson.Target.Value, lesson.DisplayOrder, lesson.PassingScore, translations, stages);
    }

    public Task<Guid?> FindVersionIdAsync(Guid courseId, Guid lessonId, CancellationToken cancellationToken) =>
        VisibleLessons(courseId).Where(x => x.Lesson.Id == lessonId)
            .Select(x => (Guid?)x.Version.Id).SingleOrDefaultAsync(cancellationToken);

    private IQueryable<VisibleLesson> VisibleLessons(Guid courseId) =>
        from course in db.PublishedCourses()
        where course.Id == courseId
        join level in db.Set<CourseLevel>().AsNoTracking() on course.Id equals level.CourseId
        join module in db.Set<CourseModule>() on level.Id equals module.CourseLevelId
        join unit in db.Set<CourseUnit>() on module.Id equals unit.CourseModuleId
        join lesson in db.Set<Lesson>() on unit.Id equals lesson.CourseUnitId
        join version in db.Set<LessonVersion>() on lesson.Id equals version.LessonId
        where !lesson.IsArchived && version.Status == PublicationState.Published
            && !db.Set<LessonVersion>().Any(x => x.LessonId == lesson.Id && x.Status == PublicationState.Published
                && x.VersionNumber > version.VersionNumber)
            && !db.Set<ContentPublication>().Any(x => x.LessonVersionId == version.Id && x.WithdrawnAtUtc != null)
        select new VisibleLesson
        {
            Course = course, Level = level, Module = module, Unit = unit, Lesson = lesson, Version = version
        };

    private sealed class VisibleLesson
    {
        public required Course Course { get; init; }
        public required CourseLevel Level { get; init; }
        public required CourseModule Module { get; init; }
        public required CourseUnit Unit { get; init; }
        public required Lesson Lesson { get; init; }
        public required LessonVersion Version { get; init; }
    }
}
