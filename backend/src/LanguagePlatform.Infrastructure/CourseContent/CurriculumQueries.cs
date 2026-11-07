using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class CurriculumQueries(LanguagePlatformDbContext db)
{
    public async Task<CurriculumCourseDto?> LevelsAsync(Guid courseId, bool authoring, CancellationToken ct)
    {
        var courses = authoring ? db.Courses.AsNoTracking() : db.PublishedCourses();
        if (!await courses.AnyAsync(x => x.Id == courseId && x.UsesFiveStageCurriculum, ct)) return null;
        var levels = await db.Set<CourseLevel>().AsNoTracking().Where(x => x.CourseId == courseId).OrderBy(x => x.DisplayOrder)
            .Select(x => new CurriculumLevelDto(x.Id, x.Code, x.DisplayOrder, FiveStageCurriculum.SlotsPerLevel)).ToListAsync(ct);
        return new CurriculumCourseDto(courseId, levels);
    }

    public async Task<IReadOnlyList<CurriculumSlotDto>?> SlotsAsync(Guid courseId, Guid levelId, bool authoring, CancellationToken ct)
    {
        var course = await LevelsAsync(courseId, authoring, ct);
        if (course is null || !course.Levels.Any(x => x.Id == levelId)) return null;
        var slots = authoring ? AuthorSlots(levelId) : new PublishedContentQueries(db).VisibleLessons(courseId)
            .Where(x => x.Level.Id == levelId)
            .Select(x => new CurriculumSlotDto(x.Lesson.CurriculumPosition!.Value, x.Lesson.Id, x.Version.Id,
                x.Version.Title, null));
        var rows = await slots.ToDictionaryAsync(x => x.Position, ct);
        return Enumerable.Range(1, FiveStageCurriculum.SlotsPerLevel)
            .Select(position => rows.GetValueOrDefault(position) ?? new CurriculumSlotDto(position, null, null, null))
            .ToArray();
    }

    private IQueryable<CurriculumSlotDto> AuthorSlots(Guid levelId) =>
        db.Set<Lesson>().AsNoTracking()
            .Where(x => x.CurriculumLevelId == levelId && x.CurriculumPosition != null && !x.IsArchived)
            .Select(x => new
            {
                x.Id, Position = x.CurriculumPosition!.Value,
                Version = db.Set<LessonVersion>().Where(v => v.LessonId == x.Id && v.UsesFiveStageCurriculum)
                    .OrderByDescending(v => v.VersionNumber)
                    .Select(v => new
                    {
                        v.Id, v.Title, v.Status
                    }).FirstOrDefault()
            })
            .Select(row => new CurriculumSlotDto(row.Position, row.Id,
                row.Version != null && row.Version.Status == PublicationState.Published ? row.Version.Id : null,
                row.Version == null ? null : row.Version.Title,
                row.Version != null && (row.Version.Status == PublicationState.Draft || row.Version.Status == PublicationState.InReview)
                    ? row.Version.Id : null));
}
