using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using LanguagePlatform.Api.Endpoints;
using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Application.Common;
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
using UglyToad.PdfPig.Content;
using UglyToad.PdfPig.Core;
using UglyToad.PdfPig.Fonts.Standard14Fonts;
using UglyToad.PdfPig.Writer;

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
        var scanner = new TestPdfScanner();
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection }))
                .ConfigureServices(services => services.AddSingleton<IPdfMalwareScanner>(scanner)));
        using var student = factory.CreateClient();
        using var author = factory.CreateClient();
        using var publisher = factory.CreateClient();
        using var evaluator = factory.CreateClient();
        using var otherAuthor = factory.CreateClient();
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
        await LoginAsync(factory, evaluator, "curriculum-evaluator@example.test", Permissions.AssessmentEvaluate);
        await LoginAsync(factory, otherAuthor, "other-curriculum-author@example.test", Permissions.ContentEdit);
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
        const string greeting = "السَّلَامُ عَلَيْكُمْ";
        DraftStage[] stages =
        [
            new("reading", 20, 3, greeting, null, questions, TeacherVideo: new("https://example.test/teacher.mp4", "Okuma")),
            new("speaking", 20, 2, greeting, null, null, EvaluationRubric: "Öğretmen tarafından verilen ölçüt",
                TeacherVideo: new("https://example.test/dialogue.mp4", "Konuşma")),
            new("listening", 20, 2, "private-listening-transcript", null,
                [new("WordBank", "{{blank}} عليك", [new("سلام", true), new("شكرا", false)], null),
                    new("FillBlank", "أهلاً {{blank}}", null, null, ["بك"])], AudioUrl: "https://example.test/listen.ogg"),
            new("writing", 20, 2, null, null,
                [new("FillBlank", "أنا {{blank}}", null, null, ["مُعَلِّمٌ"]),
                    new("WordOrder", "Cümleyi sırala", [new("طالب", false), new("أنا", false)], null, CorrectOrder: [1, 0])]),
            new("translation", 20, 2, null, null,
                [new("MultipleChoice", "Teşekkürler", [new("شُكْرًا", true), new("مرحبًا", false)], null),
                    new("ExactText", "Selamünaleyküm", null, null, [greeting, "سلام عليكم"])])
        ];
        var request = new CreateCurriculumVersion("Selamlaşma", true, AttemptSelection.Best, stages);
        using var badWeights = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request with { Stages = stages[..^1] });
        Assert.Equal(HttpStatusCode.BadRequest, badWeights.StatusCode);
        using var invalidHost = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request with
        {
            Stages = [stages[0] with { TeacherVideo = new("https://127.0.0.1/private.mp4", "Internal") }, .. stages[1..]]
        });
        Assert.Equal(HttpStatusCode.BadRequest, invalidHost.StatusCode);
        using var draftResponse = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request);
        draftResponse.EnsureSuccessStatusCode();
        var first = (await draftResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        using var secondResponse = await author.PostAsJsonAsync(slotsUrl + "/2/versions", request);
        secondResponse.EnsureSuccessStatusCode();
        var second = (await secondResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        var editedSlots = (await author.GetFromJsonAsync<CurriculumSlotDto[]>(slotsUrl))!;
        Assert.Equal(first.VersionId, editedSlots[0].DraftVersionId);
        Assert.Null(editedSlots[0].PublishedVersionId);
        var pdfRoute = $"/api/v1/admin/five-stage/versions/{first.VersionId}/reading-pdf";
        var uploadUrl = pdfRoute + $"?expectedVersion={first.Revision}&title=Reading&copyrightNotice=Teacher-owned";
        var pdf = new PdfDocumentBuilder();
        var page = pdf.AddPage(PageSize.A4);
        var font = pdf.AddStandard14Font(Standard14Font.Helvetica);
        page.AddText("Reading draft", 12, new PdfPoint(25, 700), font);
        var original = pdf.Build();
        scanner.Unavailable = true;
        using var unavailable = await UploadPdfAsync(original);
        Assert.Equal(HttpStatusCode.ServiceUnavailable, unavailable.StatusCode);
        scanner.Unavailable = false;
        scanner.Clean = false;
        using var detected = await UploadPdfAsync(original);
        Assert.Equal(HttpStatusCode.BadRequest, detected.StatusCode);
        scanner.Clean = true;
        using var invalidPdf = await UploadPdfAsync("invalid content"u8.ToArray());
        Assert.Equal(HttpStatusCode.BadRequest, invalidPdf.StatusCode);
        using var invalidPdfStructure = await UploadPdfAsync("%PDF-1.7\ninvalid content"u8.ToArray());
        Assert.Equal(HttpStatusCode.BadRequest, invalidPdfStructure.StatusCode);
        using var oversizedPdf = await UploadPdfAsync(new byte[2 * 1024 * 1024 + 1]);
        Assert.Equal(HttpStatusCode.RequestEntityTooLarge, oversizedPdf.StatusCode);
        using var uploaded = await UploadPdfAsync(original);
        uploaded.EnsureSuccessStatusCode();
        var pdfDraft = (await uploaded.Content.ReadFromJsonAsync<ReadingPdfDraftDto>())!;
        Assert.Contains("Reading draft", Assert.Single(pdfDraft.Pages).Text, StringComparison.Ordinal);
        using var stolenPdf = await otherAuthor.GetAsync(pdfRoute + "/original");
        Assert.Equal(HttpStatusCode.NotFound, stolenPdf.StatusCode);
        using var prematureReview = await author.PostAsJsonAsync($"/api/v1/admin/five-stage/versions/{first.VersionId}/review",
            new ReviewCurriculumVersion(pdfDraft.Revision));
        Assert.Equal(HttpStatusCode.BadRequest, prematureReview.StatusCode);
        using var approved = await author.PutAsJsonAsync(pdfRoute + "/review",
            new ReviewReadingPdf(pdfDraft.Revision, [new(1, [greeting])]));
        approved.EnsureSuccessStatusCode();
        var approvedPdf = (await approved.Content.ReadFromJsonAsync<ReadingPdfDraftDto>())!;
        await PublishAsync(first with { Revision = approvedPdf.Revision });
        await PublishAsync(second);
        using var invalidVersion = await author.PostAsJsonAsync(slotsUrl + "/3/versions", request with
        {
            Stages = [stages[0] with { Questions = questions[..^1] }, .. stages[1..]]
        });
        invalidVersion.EnsureSuccessStatusCode();
        await PublishAsync((await invalidVersion.Content.ReadFromJsonAsync<CurriculumDraftDto>())!, HttpStatusCode.BadRequest);
        using var release = await publisher.PostAsync(courses + $"/{curriculum.CourseId}/publish", null);
        Assert.Equal(HttpStatusCode.NoContent, release.StatusCode);

        var firstStages = await db.Set<LessonStage>().Where(x => x.LessonVersionId == first.VersionId)
            .ToDictionaryAsync(x => x.StageType, StringComparer.Ordinal);
        var firstStageIds = firstStages.Values.Select(x => x.Id).ToArray();
        var assessments = await db.Set<AssessmentEntity>().Where(x => firstStageIds.Contains(x.LessonStageId) && x.IsPublished)
            .ToDictionaryAsync(x => x.LessonStageId, x => x.Id);
        Assert.Equal(5, assessments.Count);
        Assert.Equal(2, await db.Set<ContentPublication>().CountAsync());
        var publicSlotsUrl = publicUrl + $"/levels/{level.Id}/slots";
        var studentSlots = (await student.GetFromJsonAsync<CurriculumSlotDto[]>(publicSlotsUrl))!;
        Assert.Equal(first.VersionId, studentSlots[0].PublishedVersionId);
        Assert.All(studentSlots, slot => Assert.Null(slot.DraftVersionId));
        Assert.Null(studentSlots[2].LessonId);
        var learner = $"/api/v1/me/courses/{curriculum.CourseId}";
        using var enrollmentResponse = await student.PutAsync(learner + "/enrollment", null);
        enrollmentResponse.EnsureSuccessStatusCode();
        var firstLesson = learner + $"/lessons/{first.LessonId}";
        var secondLesson = learner + $"/lessons/{second.LessonId}";
        using var unenrolledPdf = await otherAuthor.GetAsync(firstLesson + "/reading-material/original");
        Assert.Equal(HttpStatusCode.NotFound, unenrolledPdf.StatusCode);
        using var pdfDownload = await student.GetAsync(firstLesson + "/reading-material/original");
        pdfDownload.EnsureSuccessStatusCode();
        Assert.Equal("attachment", pdfDownload.Content.Headers.ContentDisposition!.DispositionType);
        Assert.Equal(original, await pdfDownload.Content.ReadAsByteArrayAsync());
        var material = (await student.GetFromJsonAsync<ApprovedReadingDto>(firstLesson + "/reading-material"))!;
        Assert.True(material.HasOriginalPdf);
        Assert.Equal(greeting, Assert.Single(material.Lines).Text);
        var lessonPayload = await student.GetStringAsync($"/api/v1/courses/{curriculum.CourseId}/lessons/{first.LessonId}");
        Assert.DoesNotContain("private-listening-transcript", lessonPayload, StringComparison.Ordinal);
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
        var readingUrl = Attempts("reading");
        var translationUrl = Attempts("translation");
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
        var speaking = await StartAsync("speaking", "spoken");
        var dialogueVideo = await student.GetFromJsonAsync<CurriculumStageMediaDto>(
            firstLesson + $"/stages/{firstStages["speaking"].Id}/media");
        Assert.Equal("available", dialogueVideo!.Status);
        Assert.Equal("https://example.test/dialogue.mp4", dialogueVideo.TeacherVideo!.Url);
        var evaluate = $"/api/v1/admin/courses/{curriculum.CourseId}/lessons/{first.LessonId}/assessments/{speaking.AssessmentId}/attempts/{speaking.Id}/speaking-evaluation";
        var rubric = await evaluator.GetFromJsonAsync<SpeakingEvaluationContextDto>(evaluate);
        Assert.Equal(stages[1].EvaluationRubric, rubric!.Rubric);
        using var studentEvaluate = await student.PostAsJsonAsync(evaluate, new EvaluateSpeaking(40));
        Assert.Equal(HttpStatusCode.Forbidden, studentEvaluate.StatusCode);
        using var missingScore = await evaluator.PostAsJsonAsync(evaluate, new { });
        Assert.Equal(HttpStatusCode.BadRequest, missingScore.StatusCode);
        using var forgedSpeaking = await student.PostAsJsonAsync(Attempts("speaking") + $"/{speaking.Id}/submit",
            new SubmitObjectiveAttempt([]));
        Assert.Equal(HttpStatusCode.Conflict, forgedSpeaking.StatusCode);
        using var spokenGrade = await evaluator.PostAsJsonAsync(evaluate, new EvaluateSpeaking(40));
        spokenGrade.EnsureSuccessStatusCode();
        var media = (await student.GetFromJsonAsync<CurriculumStageMediaDto>(
            firstLesson + $"/stages/{firstStages["listening"].Id}/media"))!;
        Assert.Equal("https://example.test/listen.ogg", media.AudioUrl);
        var listening = await StartAsync("listening", "listen");
        Assert.Equal(100, await SubmitAsync("listening", listening,
            [new(listening.Questions[0].Id, listening.Questions[0].Options[0].Id, null),
                new(listening.Questions[1].Id, null, null, "بك")]));
        var writing = await StartAsync("writing", "write");
        var ordered = writing.Questions[1];
        Assert.Equal(50, await SubmitAsync("writing", writing,
            [new(writing.Questions[0].Id, null, null, "معلم"),
                new(ordered.Id, null, null, OrderedOptionIds: [ordered.Options[1].Id, ordered.Options[0].Id])]));
        var translation = await StartAsync("translation", "translate");
        Assert.Equal(0, await SubmitAsync("translation", translation,
            [new(translation.Questions[0].Id, translation.Questions[0].Options[1].Id, null),
                new(translation.Questions[1].Id, null, null, "سلام")]));
        var failed = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.False(failed.Passed);
        Assert.Equal(50, failed.FinalScore);
        Assert.Null(failed.NextLessonId);
        using var stillLocked = await student.PutAsync(secondLesson + "/start", null);
        Assert.Equal(HttpStatusCode.BadRequest, stillLocked.StatusCode);
        var retake = await StartAsync("translation", "translate-retry");
        Assert.Equal(50, await SubmitAsync("translation", retake,
            [new(retake.Questions[0].Id, retake.Questions[0].Options[1].Id, null),
                new(retake.Questions[1].Id, null, null, "سلام عليكم")]));
        using var limit = await student.PostAsJsonAsync(translationUrl, new StartObjectiveAttempt("translate-over-limit"));
        Assert.Equal(HttpStatusCode.Conflict, limit.StatusCode);
        var complete = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.True(complete.Passed);
        Assert.Equal(60, complete.FinalScore);
        Assert.Equal(second.LessonId, complete.NextLessonId);
        using var unlocked = await student.PutAsync(secondLesson + "/start", null);
        unlocked.EnsureSuccessStatusCode();
        using var changedVersion = await author.PostAsJsonAsync(slotsUrl + "/1/versions", request with { Title = "Selamlaşma 2" });
        changedVersion.EnsureSuccessStatusCode();
        var replacement = (await changedVersion.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
        Assert.Equal(first.LessonId, replacement.LessonId);
        Assert.NotEqual(first.VersionId, replacement.VersionId);
        await PublishAsync(replacement);
        var fresh = (await student.GetFromJsonAsync<CurriculumProgressDto>(stateUrl))!;
        Assert.Equal(replacement.VersionId, fresh.VersionId);
        Assert.Null(fresh.FinalScore);
        Assert.Equal(50, (await student.GetFromJsonAsync<ObjectiveResultDto>($"/api/v1/me/assessment-attempts/{retake.Id}/result"))!.Percentage);
        var withdrawRoute = $"/api/v1/admin/lesson-versions/{replacement.VersionId}/withdraw";
        using var withdrawn = await publisher.PostAsJsonAsync(withdrawRoute, new WithdrawLessonRequest("Content correction"));
        Assert.Equal(HttpStatusCode.NoContent, withdrawn.StatusCode);
        using var withdrawRetry = await publisher.PostAsJsonAsync(withdrawRoute, new WithdrawLessonRequest("Content correction"));
        Assert.Equal(HttpStatusCode.NoContent, withdrawRetry.StatusCode);
        using var afterWithdrawal = await student.GetAsync(stateUrl);
        Assert.Equal(HttpStatusCode.NotFound, afterWithdrawal.StatusCode);
        Assert.Equal(1, await db.Set<AuditLog>().CountAsync(x => x.EntityId == replacement.VersionId && x.Action == "content.withdraw"));

        async Task<HttpResponseMessage> UploadPdfAsync(byte[] data)
        {
            using var body = new ByteArrayContent(data);
            body.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
            return await author.PostAsync(uploadUrl, body);
        }

        async Task PublishAsync(CurriculumDraftDto version, HttpStatusCode expected = HttpStatusCode.NoContent)
        {
            using var reviewResponse = await author.PostAsJsonAsync($"/api/v1/admin/five-stage/versions/{version.VersionId}/review",
                new ReviewCurriculumVersion(version.Revision));
            reviewResponse.EnsureSuccessStatusCode();
            var reviewed = (await reviewResponse.Content.ReadFromJsonAsync<CurriculumDraftDto>())!;
            using var publish = await publisher.PostAsJsonAsync($"/api/v1/admin/lesson-versions/{version.VersionId}/publish",
                new PublishLessonRequest(reviewed.Revision));
            Assert.Equal(expected, publish.StatusCode);
        }

        string Attempts(string kind) => firstLesson + $"/assessments/{assessments[firstStages[kind].Id]}/attempts";

        async Task<ObjectiveAttemptDto> StartAsync(string kind, string key)
        {
            using var response = await student.PostAsJsonAsync(Attempts(kind), new StartObjectiveAttempt(key));
            response.EnsureSuccessStatusCode();
            return (await response.Content.ReadFromJsonAsync<ObjectiveAttemptDto>())!;
        }

        async Task<decimal> SubmitAsync(string kind, ObjectiveAttemptDto current, ObjectiveAnswer[] answers)
        {
            using var response = await student.PostAsJsonAsync(Attempts(kind) + $"/{current.Id}/submit", new SubmitObjectiveAttempt(answers));
            response.EnsureSuccessStatusCode();
            return (await response.Content.ReadFromJsonAsync<ObjectiveResultDto>())!.Percentage;
        }
    });

    private sealed class TestPdfScanner : IPdfMalwareScanner
    {
        public bool Clean { get; set; } = true;
        public bool Unavailable { get; set; }

        public Task<bool> IsCleanAsync(ReadOnlyMemory<byte> original, CancellationToken cancellationToken) =>
            Unavailable ? throw new ServiceUnavailableException("PDF scanning is unavailable.") : Task.FromResult(Clean);
    }

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
