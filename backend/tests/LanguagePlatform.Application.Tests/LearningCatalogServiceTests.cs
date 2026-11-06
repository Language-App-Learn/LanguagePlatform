using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Application.Tests;

public sealed class LearningCatalogServiceTests
{
    [Fact]
    public async Task GetCatalogDataMapsDomainModelsToDtos()
    {
        var turkish = Language.Create("tr", "Turkish", "Türkçe", TextDirection.LeftToRight);
        var arabic = Language.Create("ar", "Arabic", "العربية", TextDirection.RightToLeft);
        var path = LearningPath.Create(turkish, arabic);
        var program = LearningProgram.Create("modern-language", "Modern Language", ProgramType.ModernLanguage);
        var course = new CourseDto(Guid.NewGuid(), path.Id, program.Id,
            "arabic-foundations", "Arabic Foundations", "Base description", "Published")
        {
            Localizations = [new("tr", "Arapça Temelleri", null), new("en", "Arabic Basics", "English description")]
        };
        var service = new LearningCatalogService(new StubRepository(turkish, path, program, course));

        var languages = await service.GetLanguagesAsync(CancellationToken.None);
        var paths = await service.GetLearningPathsAsync(CancellationToken.None);
        var programs = await service.GetProgramsAsync(CancellationToken.None);
        var courses = await service.GetCoursesAsync(new CourseQuery(Locale: "tr-TR"), CancellationToken.None);

        Assert.Equal("tr", Assert.Single(languages).Code);
        Assert.Equal("tr", Assert.Single(paths).SourceLanguage.Code);
        Assert.Equal("ModernLanguage", Assert.Single(programs).ProgramType);
        var selected = Assert.Single(courses.Items);
        Assert.Equal("Arapça Temelleri", selected.Title);
        Assert.Equal("English description", selected.Description);
    }

    private sealed class StubRepository(
        Language language,
        LearningPath path,
        LearningProgram program,
        CourseDto course) : ILearningCatalogRepository
    {
        public Task<IReadOnlyList<Language>> GetLanguagesAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<Language>>([language]);

        public Task<IReadOnlyList<LearningPath>> GetLearningPathsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningPath>>([path]);

        public Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningProgram>>([program]);

        public Task<IReadOnlyList<CourseDto>> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<CourseDto>>([course]);

        public Task<CourseDto?> FindCourseAsync(Guid id, CancellationToken cancellationToken) =>
            Task.FromResult<CourseDto?>(id == course.Id ? course : null);
    }
}
