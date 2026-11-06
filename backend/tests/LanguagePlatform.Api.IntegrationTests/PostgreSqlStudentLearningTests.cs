using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using LanguagePlatform.Api.Endpoints;
using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Application.Dictionary;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Application.StudentProgress;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
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
            builder.UseEnvironment("Testing").UseSetting("StudentRelease:IncludeLegacyContent", "true").ConfigureAppConfiguration((_, config) =>
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
            builder.UseEnvironment("Testing").UseSetting("StudentRelease:IncludeLegacyContent", "true").ConfigureAppConfiguration((_, config) =>
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

    [PostgreSqlFact]
    public Task FiveStageDraftsArePrivateAndCurriculumProgressIsSequential() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new DevelopmentContentSeeder(db).SeedAsync(CancellationToken.None);
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
        using var student = factory.CreateClient();
        using var author = factory.CreateClient();
        using var publisher = factory.CreateClient();
        var paths = await student.GetFromJsonAsync<LearningPathDto[]>("/api/v1/catalog/learning-paths");
        Assert.Equal(CatalogSeedIds.TurkishToArabic, Assert.Single(paths!).Id);
        var legacyId = await db.Courses.Where(x => x.Slug == DevelopmentContentSeeder.PublishedSlug).Select(x => x.Id).SingleAsync();
        using var legacy = await student.GetAsync($"/api/v1/catalog/courses/{legacyId}");
        Assert.Equal(HttpStatusCode.NotFound, legacy.StatusCode);

        const string courses = "/api/v1/admin/five-stage/courses";
        var create = new CreateCurriculumCourse("arabic-five-stage", "Arapça", null);
        using var unauthorized = await student.PostAsJsonAsync(courses, create);
        Assert.Equal(HttpStatusCode.Unauthorized, unauthorized.StatusCode);
        await LoginAsync(factory, student, "curriculum-learner@example.test");
        await LoginAsync(factory, author, "curriculum-author@example.test", Permissions.ContentEdit);
        await LoginAsync(factory, publisher, "curriculum-publisher@example.test", Permissions.ContentPublish);
        using var forbidden = await student.PostAsJsonAsync(courses, create);
        Assert.Equal(HttpStatusCode.Forbidden, forbidden.StatusCode);
        using var created = await author.PostAsJsonAsync(courses, create);
        created.EnsureSuccessStatusCode();
        var curriculum = (await created.Content.ReadFromJsonAsync<CurriculumCourseDto>())!;
        Assert.Equal(FiveStageCurriculum.Levels, curriculum.Levels.Select(x => x.Code));
        var level = curriculum.Levels[0];
        var slotsUrl = courses + $"/{curriculum.CourseId}/levels/{level.Id}/slots";
        var slots = (await author.GetFromJsonAsync<CurriculumSlotDto[]>(slotsUrl))!;
        Assert.Equal(Enumerable.Range(1, 20), slots.Select(x => x.Position));
        Assert.All(slots, slot => Assert.Null(slot.LessonId));
        var publicUrl = $"/api/v1/courses/{curriculum.CourseId}/curriculum";
        using var draftCourse = await student.GetAsync(publicUrl + "/levels");
        Assert.Equal(HttpStatusCode.NotFound, draftCourse.StatusCode);

        var questions = Enumerable.Range(1, 10).Select(i => new DraftQuestion("TrueFalse", $"سؤال {i}", null, true)).ToArray();
        DraftQuestion[] translation = [new("MultipleChoice", "السَّلَامُ عَلَيْكُمْ",
            [new("Selamünaleyküm", true), new("Teşekkürler", false)], null)];
        var stages = FiveStageCurriculum.Stages.Select(kind => new DraftStage(kind, 20, 3,
            kind == "reading" ? "السَّلَامُ عَلَيْكُمْ" : null, null,
            kind == "reading" ? questions : kind == "translation" ? translation : null)).ToArray();
        var request = new CreateCurriculumVersion("Selamlaşma", true, AttemptSelection.Best, stages);
        using var badWeights = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request with { Stages = stages[..^1] });
        Assert.Equal(HttpStatusCode.BadRequest, badWeights.StatusCode);
        using var draftResponse = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request);
        draftResponse.EnsureSuccessStatusCode();
        var first = (await draftResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        using var secondResponse = await author.PostAsJsonAsync(slotsUrl + "/2/versions", request);
        secondResponse.EnsureSuccessStatusCode();
        var second = (await secondResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        var editedSlots = (await author.GetFromJsonAsync<CurriculumSlotDto[]>(slotsUrl))!;
        Assert.Equal(first.VersionId, editedSlots[0].DraftVersionId);
        Assert.Null(editedSlots[0].PublishedVersionId);
        var reviewUrl = $"/api/v1/admin/five-stage/versions/{first.VersionId}/review";
        using var reviewResponse = await author.PostAsJsonAsync(reviewUrl, new ReviewCurriculumVersion(first.Revision));
        reviewResponse.EnsureSuccessStatusCode();
        var reviewed = (await reviewResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        using var publishBlocked = await publisher.PostAsJsonAsync($"/api/v1/admin/lesson-versions/{first.VersionId}/publish",
            new PublishLessonRequest(reviewed.Revision));
        Assert.Equal(HttpStatusCode.BadRequest, publishBlocked.StatusCode);
        Assert.Equal(PublicationState.InReview, await db.Set<LessonVersion>().Where(x => x.Id == first.VersionId)
            .Select(x => x.Status).SingleAsync());
        Assert.Empty(await db.Set<ContentPublication>().Where(x => x.LessonVersionId == first.VersionId).ToListAsync());

        // Synthetic published fixtures exercise the learner contract while media publication is gated.
        var course = await db.Courses.SingleAsync(x => x.Id == curriculum.CourseId);
        course.SubmitForReview();
        course.Publish();
        var firstStages = await PublishFixtureAsync(first.VersionId);
        var publicSlotsUrl = publicUrl + $"/levels/{level.Id}/slots";
        await PublishFixtureAsync(second.VersionId);
        await db.SaveChangesAsync();
        var readingStageId = firstStages.Single(x => x.StageType == "reading").Id;
        var translationStageId = firstStages.Single(x => x.StageType == "translation").Id;
        var fixtureAssessments = db.Set<AssessmentEntity>().Where(x => x.LessonStageId == readingStageId || x.LessonStageId == translationStageId);
        await fixtureAssessments.ExecuteUpdateAsync(x => x.SetProperty(a => a.IsPublished, true));
        var assessments = await fixtureAssessments.ToDictionaryAsync(x => x.LessonStageId, x => x.Id);
        Assert.Equal("السَّلَامُ عَلَيْكُمْ", await db.Set<LessonStageContent>().Where(x => x.LessonStageId == readingStageId)
            .Select(x => x.Body).SingleAsync());
        var studentSlots = (await student.GetFromJsonAsync<CurriculumSlotDto[]>(publicSlotsUrl))!;
        Assert.Equal(first.VersionId, studentSlots[0].PublishedVersionId);
        Assert.All(studentSlots, slot => Assert.Null(slot.DraftVersionId));
        Assert.Null(studentSlots[2].LessonId);
        var learner = $"/api/v1/me/courses/{course.Id}";
        using var enrollmentResponse = await student.PutAsync(learner + "/enrollment", null);
        enrollmentResponse.EnsureSuccessStatusCode();
        var firstLesson = learner + $"/lessons/{first.LessonId}";
        var secondLesson = learner + $"/lessons/{second.LessonId}";
        using var locked = await student.PutAsync(secondLesson + "/start", null);
        Assert.Equal(HttpStatusCode.BadRequest, locked.StatusCode);
        using var started = await student.PutAsync(firstLesson + "/start", null);
        started.EnsureSuccessStatusCode();
        Assert.Null((await started.Content.ReadFromJsonAsync<LessonProgressDto>())!.Score);
        var stateUrl = firstLesson + "/curriculum-progress";
        var initial = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.Equal("available", initial.Stages[0].Status);
        Assert.All(initial.Stages.Skip(1), stage => Assert.Equal("locked", stage.Status));
        Assert.Null(initial.FinalScore);
        var readingUrl = firstLesson + $"/assessments/{assessments[readingStageId]}/attempts";
        var translationUrl = firstLesson + $"/assessments/{assessments[translationStageId]}/attempts";
        using var lockedStage = await student.PostAsJsonAsync(translationUrl, new StartObjectiveAttempt("translation-too-early"));
        Assert.Equal(HttpStatusCode.Conflict, lockedStage.StatusCode);
        using var quiz = await student.PostAsJsonAsync(readingUrl, new StartObjectiveAttempt("curriculum-reading"));
        quiz.EnsureSuccessStatusCode();
        Assert.DoesNotContain("correct", await quiz.Content.ReadAsStringAsync(), StringComparison.OrdinalIgnoreCase);
        var attempt = (await quiz.Content.ReadFromJsonAsync<ObjectiveAttemptDto>())!;
        Assert.Equal(10, attempt.Questions.Count);
        using var graded = await student.PostAsJsonAsync(readingUrl + $"/{attempt.Id}/submit",
            new SubmitObjectiveAttempt(attempt.Questions.Select((q, index) => new ObjectiveAnswer(q.Id, null, index < 6)).ToArray()));
        graded.EnsureSuccessStatusCode();
        Assert.Equal(60, (await graded.Content.ReadFromJsonAsync<ObjectiveResultDto>())!.Percentage);
        var partial = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.Equal(60, partial.Stages[0].Score);
        Assert.Equal(1, partial.Stages[0].Attempts);
        Assert.Equal("available", partial.Stages[1].Status);
        Assert.Null(partial.FinalScore);
        var progress = await db.Set<LessonProgress>().SingleAsync(x => x.LessonVersionId == first.VersionId);
        var now = DateTime.UtcNow;
        foreach (var stage in firstStages.Where(x => x.Id != readingStageId))
        {
            var stageProgress = new StageProgress
            {
                LessonStageId = stage.Id, LessonProgressId = progress.Id, LessonVersionId = first.VersionId
            };
            stageProgress.RecordScore(60, now);
            db.Add(stageProgress);
        }
        progress.RecordScore(60, true, now);
        await db.SaveChangesAsync();
        var complete = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.True(complete.Passed);
        Assert.Equal(60, complete.FinalScore);
        Assert.Equal(second.LessonId, complete.NextLessonId);
        using var unlocked = await student.PutAsync(secondLesson + "/start", null);
        unlocked.EnsureSuccessStatusCode();

        async Task<List<LessonStage>> PublishFixtureAsync(Guid versionId)
        {
            var version = await db.Set<LessonVersion>().SingleAsync(x => x.Id == versionId);
            var lessonStages = await db.Set<LessonStage>().Where(x => x.LessonVersionId == versionId).ToListAsync();
            if (version.Status == PublicationState.Draft) version.SubmitForReview();
            version.Publish(lessonStages, DateTime.UtcNow);
            return lessonStages;
        }
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
