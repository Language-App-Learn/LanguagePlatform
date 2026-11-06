using LanguagePlatform.Application.Catalog;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class LanguagePlatformApiFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureServices(services =>
        {
            services.RemoveAll<ILearningCatalogService>();
            services.AddSingleton<ILearningCatalogService, StubLearningCatalogService>();
        });
    }

    private sealed class StubLearningCatalogService : ILearningCatalogService
    {
        private static readonly LanguageDto Turkish = new(
            Guid.Parse("10000000-0000-0000-0000-000000000001"),
            "tr",
            "Turkish",
            "Türkçe",
            "LeftToRight",
            true);

        public Task<IReadOnlyList<LanguageDto>> GetLanguagesAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LanguageDto>>([Turkish]);

        public Task<IReadOnlyList<LearningPathDto>> GetLearningPathsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningPathDto>>([]);

        public Task<IReadOnlyList<LearningProgramDto>> GetProgramsAsync(CancellationToken cancellationToken) =>
            Task.FromResult<IReadOnlyList<LearningProgramDto>>([]);

        public Task<CoursePage> GetCoursesAsync(CourseQuery query, CancellationToken cancellationToken)
        {
            query.Validate();
            return Task.FromResult(new CoursePage([], null));
        }

        public Task<CourseDto?> FindCourseAsync(Guid id, string? locale, CancellationToken cancellationToken) =>
            Task.FromResult<CourseDto?>(null);
    }
}
