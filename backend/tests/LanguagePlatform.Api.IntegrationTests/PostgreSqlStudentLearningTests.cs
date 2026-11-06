using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using LanguagePlatform.Api.Endpoints;
using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Dictionary;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Platform;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Domain.Dictionary;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlStudentLearningTests
{
    [PostgreSqlFact]
    public Task LearnerWorkflowIsIdempotentPrivateAndServerGraded() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new DevelopmentContentSeeder(db).SeedAsync(CancellationToken.None);
        var courseId = await db.Courses.Where(x => x.Slug == DevelopmentContentSeeder.PublishedSlug)
            .Select(x => x.Id).SingleAsync();
        var lessonId = await db.Set<Lesson>().Select(x => x.Id).SingleAsync();
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
        using var first = factory.CreateClient();
        using var second = factory.CreateClient();
        var course = $"/api/v1/me/courses/{courseId}";
        using var anonymous = await first.GetAsync(course + "/progress");
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
        await LoginAsync(factory, first, "first@example.test");
        await LoginAsync(factory, second, "second@example.test");

        using var enrollment = await first.PutAsync(course + "/enrollment", null);
        enrollment.EnsureSuccessStatusCode();
        using var enrollRetry = await first.PutAsync(course + "/enrollment", null);
        enrollRetry.EnsureSuccessStatusCode();
        Assert.Equal((await enrollment.Content.ReadFromJsonAsync<EnrollmentDto>())!.Id,
            (await enrollRetry.Content.ReadFromJsonAsync<EnrollmentDto>())!.Id);
        using var forbidden = await second.GetAsync(course + "/progress");
        Assert.Equal(HttpStatusCode.NotFound, forbidden.StatusCode);

        var opened = (await first.GetFromJsonAsync<CourseProgressDto>(course + "/progress"))!;
        Assert.Null(opened.ContinueFrom);
        using var start = await first.PutAsync(course + $"/lessons/{lessonId}/start", null);
        start.EnsureSuccessStatusCode();
        using var retry = await first.PutAsync(course + $"/lessons/{lessonId}/start", null);
        retry.EnsureSuccessStatusCode();
        var progress = (await first.GetFromJsonAsync<CourseProgressDto>(course + "/progress"))!;
        Assert.Equal(lessonId, progress.ContinueFrom!.LessonId);
        Assert.False(progress.ContinueFrom.IsPassed);
        Assert.Equal(0, progress.CompletedLessons);
        var completed = (await first.GetFromJsonAsync<LessonProgressPage>(course + "/lessons/progress?completedOnly=true"))!;
        Assert.Empty(completed.Items);
        Assert.Equal(1, await db.Set<LearningActivity>().CountAsync());
        Assert.Equal(1, await db.Set<LessonProgress>().CountAsync());

        var assessmentId = await db.Set<AssessmentEntity>().Select(x => x.Id).SingleAsync();
        var attempts = course + $"/lessons/{lessonId}/assessments/{assessmentId}/attempts";
        var startRequest = new StartObjectiveAttempt("fixture-attempt-1");
        using var quiz = await first.PostAsJsonAsync(attempts, startRequest);
        quiz.EnsureSuccessStatusCode();
        var json = await quiz.Content.ReadAsStringAsync();
        Assert.DoesNotContain("correct", json, StringComparison.OrdinalIgnoreCase);
        var attempt = (await quiz.Content.ReadFromJsonAsync<ObjectiveAttemptDto>())!;
        var choice = attempt.Questions.Single(x => x.Kind == "MultipleChoice");
        var boolean = attempt.Questions.Single(x => x.Kind == "TrueFalse");
        using var quizReplay = await first.PostAsJsonAsync(attempts, startRequest);
        quizReplay.EnsureSuccessStatusCode();
        Assert.Equal(attempt.Id, (await quizReplay.Content.ReadFromJsonAsync<ObjectiveAttemptDto>())!.Id);
        var submit = attempts + $"/{attempt.Id}/submit";
        var correct = new SubmitObjectiveAttempt([new(choice.Id, choice.Options[0].Id, null), new(boolean.Id, null, true)]);
        using var stolen = await second.PostAsJsonAsync(submit, correct);
        Assert.Equal(HttpStatusCode.NotFound, stolen.StatusCode);
        using var invalid = await first.PostAsJsonAsync(submit,
            new SubmitObjectiveAttempt([new(choice.Id, Guid.NewGuid(), null), new(boolean.Id, null, true)]));
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
        using var grade = await first.PostAsJsonAsync(submit, correct);
        grade.EnsureSuccessStatusCode();
        var result = (await grade.Content.ReadFromJsonAsync<ObjectiveResultDto>())!;
        Assert.Equal(100, result.Percentage);
        Assert.Equal(60, result.PassingScore);
        Assert.True(result.Passed);
        using var gradeReplay = await first.PostAsJsonAsync(submit,
            new SubmitObjectiveAttempt([new(choice.Id, choice.Options[1].Id, null), new(boolean.Id, null, false)]));
        gradeReplay.EnsureSuccessStatusCode();
        Assert.Equal(result, await gradeReplay.Content.ReadFromJsonAsync<ObjectiveResultDto>());
        Assert.Equal(result, await first.GetFromJsonAsync<ObjectiveResultDto>($"/api/v1/me/assessment-attempts/{attempt.Id}/result"));
        Assert.Equal(2, await db.Set<Domain.Assessment.StudentAnswer>().CountAsync());
        Assert.Equal(1, await db.Set<AssessmentResult>().CountAsync());
        Assert.Equal(1, (await first.GetFromJsonAsync<CourseProgressDto>(course + "/progress"))!.CompletedLessons);
        using var attemptTwo = await first.PostAsJsonAsync(attempts, new StartObjectiveAttempt("fixture-attempt-2"));
        attemptTwo.EnsureSuccessStatusCode();
        using var attemptLimit = await first.PostAsJsonAsync(attempts, new StartObjectiveAttempt("fixture-attempt-3"));
        Assert.Equal(HttpStatusCode.Conflict, attemptLimit.StatusCode);

        var word = await db.Set<DictionaryEntry>().SingleAsync();
        var vocabulary = $"/api/v1/me/vocabulary/{word.Id}";
        using var favorite = await first.PutAsJsonAsync(vocabulary + "/favorite", new UpdateFavorite(true));
        Assert.Equal(HttpStatusCode.NoContent, favorite.StatusCode);
        var mine = await first.GetFromJsonAsync<VocabularyDetailDto>(vocabulary);
        var theirs = await second.GetFromJsonAsync<VocabularyDetailDto>(vocabulary);
        Assert.True(mine!.Word.IsFavorite);
        Assert.False(theirs!.Word.IsFavorite);
        Assert.Equal("Merhaba", Assert.Single(Assert.Single(mine.Senses).Translations).Text);
        var favorites = await first.GetFromJsonAsync<VocabularyPage>($"/api/v1/me/vocabulary?favoritesOnly=true&targetLanguageId={word.LanguageId}");
        Assert.Equal(word.Id, Assert.Single(favorites!.Items).Id);
        using var remove = await first.PutAsJsonAsync(vocabulary + "/favorite", new UpdateFavorite(false));
        Assert.Equal(HttpStatusCode.NoContent, remove.StatusCode);
        Assert.False((await first.GetFromJsonAsync<VocabularyDetailDto>(vocabulary))!.Word.IsFavorite);
    });

    [PostgreSqlFact]
    public Task PublicationRequiresPermissionAndWritesAuditAndOutbox() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new DevelopmentContentSeeder(db).SeedAsync(CancellationToken.None);
        var lessonId = await db.Set<Lesson>().Select(x => x.Id).SingleAsync();
        var version = new LessonVersion { LessonId = lessonId, VersionNumber = 2, Title = "Review", PassingScore = 60 };
        version.SubmitForReview();
        db.Add(version);
        db.Add(new LessonStage
        {
            LessonVersionId = version.Id, StageType = "Reading", DisplayOrder = 1, Weight = 100,
            IsActive = true, IsRequired = true, MinimumScore = 0, MaximumAttempts = 1,
            EstimatedDurationSeconds = 60, SettingsSchemaVersion = 1, SettingsJson = "{}"
        });
        await db.SaveChangesAsync();
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
        using var student = factory.CreateClient();
        using var publisher = factory.CreateClient();
        var url = $"/api/v1/admin/lesson-versions/{version.Id}/publish";
        var request = new PublishLessonRequest(version.Version);
        using var anonymous = await student.PostAsJsonAsync(url, request);
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
        await LoginAsync(factory, student, "learner@example.test");
        using var denied = await student.PostAsJsonAsync(url, request);
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);
        await LoginAsync(factory, publisher, "publisher@example.test", Permissions.ContentPublish);
        using var stale = await publisher.PostAsJsonAsync(url, new PublishLessonRequest(version.Version + 1));
        Assert.Equal(HttpStatusCode.Conflict, stale.StatusCode);
        using var published = await publisher.PostAsJsonAsync(url, request);
        Assert.Equal(HttpStatusCode.NoContent, published.StatusCode);
        Assert.Equal(1, await db.Set<ContentPublication>().CountAsync(x => x.LessonVersionId == version.Id));
        Assert.Equal(1, await db.Set<OutboxMessage>().CountAsync(x => x.EventType == "LessonPublished"));
        Assert.Equal(1, await db.Set<AuditLog>().CountAsync(x => x.EntityId == version.Id));
    });

    private static async Task LoginAsync(WebApplicationFactory<Program> factory, HttpClient client, string email, string? permission = null)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        const string password = "Fixture-Password1!";
        var user = new ApplicationUser
        {
            Id = Guid.NewGuid(), Email = email, UserName = email, EmailConfirmed = true
        };
        var created = await users.CreateAsync(user, password);
        Assert.True(created.Succeeded);
        if (permission is not null)
            Assert.True((await users.AddClaimAsync(user, new Claim("permission", permission))).Succeeded);
        using var login = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
        login.EnsureSuccessStatusCode();
        var token = (await login.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token.AccessToken);
    }
}
