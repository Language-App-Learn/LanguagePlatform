using System.Net;
using System.Net.Http.Json;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Dictionary;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Infrastructure.CourseContent;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlPublishedContentTests
{
    [PostgreSqlFact]
    public Task EmptyPlatformStartsWithObsoleteFlagsAndReturnsEmptyCollections() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new CatalogDataSeeder(db).SeedAsync();
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Development").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["ConnectionStrings:LanguagePlatform"] = connection,
                    ["Database:SeedDemoContentOnStartup"] = "true",
                    ["StudentRelease:IncludeLegacyContent"] = "true"
                })));
        using var client = factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost") });
        var courses = await client.GetFromJsonAsync<CourseDto[]>("/api/v1/catalog/courses");
        Assert.Empty(courses!);
        var paths = await client.GetFromJsonAsync<LearningPathDto[]>("/api/v1/catalog/learning-paths");
        Assert.Equal(CatalogSeedIds.TurkishToArabic, Assert.Single(paths!).Id);
        Assert.Equal(0, await db.Courses.CountAsync());
        Assert.Equal(0, await db.Set<Lesson>().CountAsync());
        Assert.Equal(0, await db.Set<DictionaryEntry>().CountAsync());

        // Simulate a published catalog entry with no visible lessons, as after withdrawal.
        var empty = Course.Create(CatalogSeedIds.TurkishToArabic, CatalogSeedIds.ModernLanguage, "empty-test", "Empty test course");
        empty.EnableFiveStageCurriculum();
        empty.SubmitForReview();
        empty.Publish();
        var level = new CourseLevel { CourseId = empty.Id, Code = "A1", DisplayOrder = 1 };
        db.AddRange(empty, level);
        await db.SaveChangesAsync();

        var outline = (await client.GetFromJsonAsync<LessonOutlinePage>($"/api/v1/courses/{empty.Id}/lessons"))!;
        Assert.Empty(outline.Items);
        Assert.Null(outline.NextOffset);
        var slots = (await client.GetFromJsonAsync<CurriculumSlotDto[]>(
            $"/api/v1/courses/{empty.Id}/curriculum/levels/{level.Id}/slots"))!;
        Assert.Equal(Enumerable.Range(1, 20), slots.Select(x => x.Position));
        Assert.All(slots, slot =>
        {
            Assert.Null(slot.LessonId);
            Assert.Null(slot.Title);
        });
    });

    [PostgreSqlFact]
    public Task OnlyPublishedVersionsAreVisibleAndTextSurvivesJson() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        var seeder = new LegacyContentFixture(db);
        await seeder.SeedAsync(CancellationToken.None);
        await seeder.SeedAsync(CancellationToken.None);
        Assert.Equal(2, await db.Courses.CountAsync());
        var course = await db.Courses.SingleAsync(x => x.Slug == LegacyContentFixture.PublishedSlug);
        var draft = await db.Courses.SingleAsync(x => x.Slug == LegacyContentFixture.DraftSlug);
        var published = await db.Set<LessonVersion>().SingleAsync();
        db.Add(new LessonVersion
        {
            LessonId = published.LessonId, VersionNumber = 2, Title = "Hidden draft", PassingScore = 80
        });
        var studentId = await db.Users.Select(x => x.Id).SingleAsync();
        var enrollment = new Enrollment { StudentId = studentId, CourseId = course.Id, EnrolledAtUtc = DateTime.UtcNow, Status = "Active" };
        var progress = new LessonProgress { EnrollmentId = enrollment.Id, LessonVersionId = published.Id };
        progress.RecordScore(60, true, DateTime.UtcNow);
        db.AddRange(enrollment, progress);
        await db.SaveChangesAsync();
        var query = new PublishedContentQueries(db);
        Assert.Single((await query.ListAsync(course.Id, new OutlineQuery(), CancellationToken.None))!.Items);
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").UseSetting("Database:SeedDemoContentOnStartup", "true").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection }))
                .ConfigureServices(services => services.AddSingleton(new StudentReleaseOptions(true))));
        using var client = factory.CreateClient();
        var outline = (await client.GetFromJsonAsync<LessonOutlinePage>($"/api/v1/courses/{course.Id}/lessons"))!;
        var summary = Assert.Single(outline.Items);
        Assert.Equal(published.Id, summary.VersionId);
        Assert.Equal("A1", summary.LevelCode);
        var detail = (await client.GetFromJsonAsync<PublishedLessonDto>($"/api/v1/courses/{course.Id}/lessons/{summary.Id}"))!;
        Assert.Equal(1, detail.VersionNumber);
        Assert.Equal("ar", detail.TargetLanguageCode);
        Assert.Equal("مرحبا", Assert.Single(Assert.Single(detail.Stages).Texts).Text);
        using var notFound = await client.GetAsync($"/api/v1/courses/{draft.Id}/lessons");
        Assert.Equal(HttpStatusCode.NotFound, notFound.StatusCode);
        var storedProgress = await db.Set<LessonProgress>().AsNoTracking().SingleAsync(x => x.Id == progress.Id);
        Assert.True(storedProgress.IsPassed);
        Assert.Equal(60, storedProgress.Score);
    });
}
