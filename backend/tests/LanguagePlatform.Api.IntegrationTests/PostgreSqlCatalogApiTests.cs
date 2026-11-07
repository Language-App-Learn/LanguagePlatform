using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlCatalogApiTests
{
    [PostgreSqlFact]
    public Task PublishedCatalogIsDirectionalLocalizedAndPaged() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new CatalogDataSeeder(db).SeedAsync();
        var path = await db.LearningPaths.SingleAsync(x => x.Id == CatalogSeedIds.TurkishToArabic);
        var reverse = await db.LearningPaths.SingleAsync(x => x.Id == CatalogSeedIds.ArabicToTurkish);
        var program = await db.LearningPrograms.FirstAsync();
        var first = Course.Create(path.Id, program.Id, "a-published", "Base", status: CourseStatus.Published);
        var second = Course.Create(path.Id, program.Id, "b-published", "Second", status: CourseStatus.Published);
        var hidden = Course.Create(path.Id, program.Id, "c-draft", "Draft");
        db.Courses.AddRange(first, second, hidden,
            Course.Create(reverse.Id, program.Id, "reverse", "Reverse", status: CourseStatus.Published));
        db.Add(new CourseLocalization { CourseId = first.Id, LanguageId = CatalogSeedIds.Turkish, Title = "Türkçe başlık" });
        db.Add(new CourseLevel { CourseId = first.Id, Code = "A1", DisplayOrder = 1 });
        await db.SaveChangesAsync();

        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Development").UseSetting("StudentRelease:IncludeLegacyContent", "true").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
        using var client = factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost") });

        using var ready = await client.GetAsync("/health/ready");
        Assert.Equal(HttpStatusCode.OK, ready.StatusCode);
        using var response = await client.GetAsync($"/api/v1/catalog/courses?source=tr&target=ar&locale=tr-TR&programId={program.Id}&limit=1");
        response.EnsureSuccessStatusCode();
        var page = Assert.Single((await response.Content.ReadFromJsonAsync<CourseDto[]>())!);
        Assert.Equal(first.Id, page.Id);
        Assert.Equal("Türkçe başlık", page.Title);
        Assert.Equal("ar", page.TargetLanguageCode);
        Assert.Equal("A1", Assert.Single(page.Levels).Code);
        var cursor = Assert.Single(response.Headers.GetValues("X-Next-Cursor"));
        using var next = await client.GetAsync($"/api/v1/catalog/courses?learningPathId={path.Id}&after={cursor}&limit=1");
        next.EnsureSuccessStatusCode();
        Assert.Equal(second.Id, Assert.Single((await next.Content.ReadFromJsonAsync<CourseDto[]>())!).Id);
        Assert.False(next.Headers.Contains("X-Next-Cursor"));
        using var draft = await client.GetAsync($"/api/v1/catalog/courses/{hidden.Id}");
        Assert.Equal(HttpStatusCode.NotFound, draft.StatusCode);
        using var invalid = await client.GetAsync("/api/v1/catalog/courses?limit=0");
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
        Assert.Equal("application/problem+json", invalid.Content.Headers.ContentType?.MediaType);

        var document = await client.GetStringAsync("/openapi/v1.json");
        using var spec = JsonDocument.Parse(document);
        Assert.StartsWith("3.1.", spec.RootElement.GetProperty("openapi").GetString(), StringComparison.Ordinal);
        var paths = spec.RootElement.GetProperty("paths");
        Assert.True(paths.TryGetProperty("/api/v1/catalog/courses/{id}", out _));
        Assert.True(paths.TryGetProperty("/api/v1/catalog/courses", out var catalog));
        Assert.Contains(catalog.GetProperty("get").GetProperty("parameters").EnumerateArray(),
            parameter => parameter.GetProperty("name").GetString() == "locale");
        Assert.False(catalog.GetProperty("get").TryGetProperty("security", out _));
        Assert.Equal("bearer", spec.RootElement.GetProperty("components").GetProperty("securitySchemes")
            .GetProperty("Bearer").GetProperty("scheme").GetString());
        Assert.True(paths.GetProperty("/api/v1/me").GetProperty("get").GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.False(paths.GetProperty("/api/v1/courses/{courseId}/curriculum/levels").GetProperty("get")
            .TryGetProperty("security", out _));
        Assert.True(paths.GetProperty("/api/v1/admin/five-stage/courses").GetProperty("post")
            .GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.True(paths.GetProperty("/api/v1/me/courses/{courseId}/lessons/{lessonId}/curriculum-progress").GetProperty("get")
            .GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.True(paths.GetProperty("/api/v1/admin/five-stage/versions/{versionId}/reading-pdf").GetProperty("post")
            .GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.True(paths.GetProperty("/api/v1/admin/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts/{attemptId}/speaking-evaluation")
            .GetProperty("post").GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.True(paths.GetProperty("/api/v1/admin/lesson-versions/{versionId}/withdraw").GetProperty("post")
            .GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.True(paths.GetProperty("/api/v1/me/privacy/export").GetProperty("get")
            .GetProperty("security")[0].TryGetProperty("Bearer", out _));
        Assert.Equal("binary", spec.RootElement.GetProperty("components").GetProperty("schemas")
            .GetProperty("Stream").GetProperty("format").GetString());
        Assert.True(paths.GetProperty("/api/v1/me/courses/{courseId}/lessons/{lessonId}/reading-material/original")
            .GetProperty("get").GetProperty("responses").GetProperty("200").GetProperty("content")
            .TryGetProperty("application/pdf", out _));
        if (Environment.GetEnvironmentVariable("LANGUAGEPLATFORM_OPENAPI_OUTPUT") is { Length: > 0 } output)
            await File.WriteAllTextAsync(output, document);
    });
}
