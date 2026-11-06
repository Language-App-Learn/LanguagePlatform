using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Catalog;

internal static class PublishedCatalogQuery
{
    public static IQueryable<Course> PublishedCourses(this LanguagePlatformDbContext db) => db.Courses.AsNoTracking()
        .Where(x => x.Status == CourseStatus.Published && x.LearningProgram.IsActive
            && x.LearningPath.IsActive && x.LearningPath.SourceLanguage.IsActive
            && x.LearningPath.TargetLanguage.IsActive);
}
