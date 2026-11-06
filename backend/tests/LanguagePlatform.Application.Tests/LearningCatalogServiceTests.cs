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
        var course = Course.Create(path, program, "arabic-foundations", "Arabic Foundations");
        var service = new LearningCatalogService(new StubRepository(turkish, path, program, course));

        var languages = await service.GetLanguagesAsync(CancellationToken.None);
        var paths = await service.GetLearningPathsAsync(CancellationToken.None);
        var programs = await service.GetProgramsAsync(CancellationToken.None);
        var courses = await service.GetCoursesAsync(CancellationToken.None);

        Assert.Equal("tr", Assert.Single(languages).Code);
        Assert.Equal("tr", Assert.Single(paths).SourceLanguage.Code);
        Assert.Equal("ModernLanguage", Assert.Single(programs).ProgramType);
        Assert.Equal("Draft", Assert.Single(courses).Status);
    }

    private sealed class StubRepository(
        Language language,
        LearningPath path,
        LearningProgram program,
        Course course) : ILearningCatalogRepository
    {
        public Task<IReadOnlyList<Language>> GetLanguagesAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<Language>>([language]);

        public Task<IReadOnlyList<LearningPath>> GetLearningPathsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningPath>>([path]);

        public Task<IReadOnlyList<LearningProgram>> GetProgramsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningProgram>>([program]);

        public Task<IReadOnlyList<Course>> GetCoursesAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<Course>>([course]);
    }
}
