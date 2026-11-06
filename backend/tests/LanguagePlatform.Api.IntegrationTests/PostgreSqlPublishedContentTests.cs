using System.Net;
using System.Net.Http.Json;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Infrastructure.CourseContent;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlPublishedContentTests
{
    [PostgreSqlFact]
    public Task OnlyPublishedVersionsAreVisibleAndTextSurvivesJson() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        var seeder = new DevelopmentContentSeeder(db);
        await seeder.SeedAsync(CancellationToken.None);
        await seeder.SeedAsync(CancellationToken.None);
        Assert.Equal(2, await db.Courses.CountAsync());
        var course = await db.Courses.SingleAsync(x => x.Slug == DevelopmentContentSeeder.PublishedSlug);
        var draft = await db.Courses.SingleAsync(x => x.Slug == DevelopmentContentSeeder.DraftSlug);
        var published = await db.Set<LessonVersion>().SingleAsync();
        db.Add(new LessonVersion
        {
            LessonId = published.LessonId, VersionNumber = 2, Title = "Hidden draft", PassingScore = 80
        });
        await db.SaveChangesAsync();
        var query = new PublishedContentQueries(db);
        Assert.Single((await query.ListAsync(course.Id, new OutlineQuery(), CancellationToken.None))!.Items);
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
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
    });
}
