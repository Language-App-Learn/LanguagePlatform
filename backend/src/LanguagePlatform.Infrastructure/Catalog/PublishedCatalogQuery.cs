using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Catalog;

internal static class PublishedCatalogQuery
{
    public static IQueryable<LearningPath> EligiblePaths(this LanguagePlatformDbContext db)
    {
        var paths = db.LearningPaths.AsNoTracking()
            .Where(x => x.IsActive && x.SourceLanguage.IsActive && x.TargetLanguage.IsActive);
        var turkish = LanguageCode.Create("tr");
        var arabic = LanguageCode.Create("ar");
        return db.IncludeLegacyContent ? paths : paths.Where(x => x.SourceLanguage.Code == turkish && x.TargetLanguage.Code == arabic);
    }

    public static IQueryable<Course> PublishedCourses(this LanguagePlatformDbContext db)
    {
        var paths = db.EligiblePaths();
        var published = db.Courses.AsNoTracking().Where(x => x.Status == CourseStatus.Published
            && x.LearningProgram.IsActive && paths.Any(path => path.Id == x.LearningPathId));
        return db.IncludeLegacyContent ? published
            : published.Where(x => x.UsesFiveStageCurriculum && x.LearningProgram.Code == "modern-language");
    }
}
