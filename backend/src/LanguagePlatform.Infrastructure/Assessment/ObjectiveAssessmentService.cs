using System.Text.Json;
using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;

namespace LanguagePlatform.Infrastructure.Assessment;

public sealed class ObjectiveAssessmentService(LanguagePlatformDbContext db, IPublishedContentQueries content, TimeProvider clock)
{
    private const string Choice = "MultipleChoice";
    private const string Boolean = "TrueFalse";
    private const int MaximumQuestions = 100;

    public async Task<ObjectiveAttemptDto?> StartAsync(Guid userId, Guid courseId, Guid lessonId, Guid assessmentId,
        StartObjectiveAttempt request, CancellationToken ct)
    {
        var key = Guard.Text(request.IdempotencyKey, 128, nameof(request.IdempotencyKey));
        var available = await FindAvailableAsync(userId, courseId, lessonId, assessmentId, ct);
        if (available is null) return null;
        var existing = await FindByKeyAsync(userId, key, ct);
        if (existing is not null) return await ReplayAsync(existing, assessmentId, ct);
        var number = (await db.Set<AssessmentAttempt>()
            .Where(x => x.StudentId == userId && x.AssessmentId == assessmentId)
            .MaxAsync(x => (int?)x.AttemptNumber, ct) ?? 0) + 1;
        var maximum = await db.Set<LessonStage>().Where(x => x.Id == available.LessonStageId)
            .Select(x => x.MaximumAttempts).SingleAsync(ct);
        if (number > Math.Min(maximum, available.MaximumAttempts)) throw new StateConflictException("Attempt limit reached.");

        var questions = await (from link in db.Set<AssessmentQuestion>().AsNoTracking()
            where link.AssessmentId == assessmentId
            join question in db.Set<Question>() on link.QuestionId equals question.Id
            orderby link.DisplayOrder
            select new { Link = link, Question = question }).Take(MaximumQuestions + 1).ToListAsync(ct);
        if (questions.Count is 0 or > MaximumQuestions || questions.Any(x => x.Question.IsArchived))
            throw new StateConflictException("The assessment does not have a supported published question set.");
        var questionIds = questions.Select(x => x.Question.Id).ToArray();
        var options = (await db.Set<QuestionOption>().AsNoTracking().Where(x => questionIds.Contains(x.QuestionId))
            .OrderBy(x => x.DisplayOrder).ToListAsync(ct)).ToLookup(x => x.QuestionId);
        var now = UtcNow();
        var attempt = new AssessmentAttempt
        {
            StudentId = userId, AssessmentId = assessmentId, AttemptNumber = number, IdempotencyKey = key,
            StartedAtUtc = now, MaximumScore = questions.Sum(x => x.Link.MaximumScore),
            PassingScoreSnapshot = available.PassingScore,
            DeadlineUtc = available.TimeLimitSeconds is { } seconds ? now.AddSeconds(seconds) : null
        };
        var snapshots = questions.Select(x => Snapshot(attempt.Id, x.Link, x.Question, options[x.Question.Id].ToArray())).ToArray();
        db.Add(attempt);
        db.AddRange(snapshots);
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException error) when (error.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        {
            foreach (var snapshot in snapshots) db.Entry(snapshot).State = EntityState.Detached;
            db.Entry(attempt).State = EntityState.Detached;
            var winner = await FindByKeyAsync(userId, key, ct);
            if (winner is not null) return await ReplayAsync(winner, assessmentId, ct);
            throw new StateConflictException("A concurrent attempt was started. Reload the assessment before retrying.");
        }
        return ToAttempt(attempt, snapshots);
    }

    public async Task<ObjectiveResultDto?> SubmitAsync(Guid userId, Guid courseId, Guid lessonId, Guid assessmentId,
        Guid attemptId, SubmitObjectiveAttempt request, CancellationToken ct)
    {
        var attempt = await db.Set<AssessmentAttempt>().SingleOrDefaultAsync(x =>
            x.Id == attemptId && x.StudentId == userId && x.AssessmentId == assessmentId, ct);
        if (attempt is null || attempt.PassingScoreSnapshot is null) return null;
        var available = await FindAvailableAsync(userId, courseId, lessonId, assessmentId, ct);
        if (available is null) return null;
        if (attempt.Status == AttemptStatus.Completed) return Result(attempt);
        if (attempt.Status != AttemptStatus.InProgress) throw new StateConflictException("This attempt is not open.");
        var now = UtcNow();
        if (attempt.DeadlineUtc <= now) throw new StateConflictException("The attempt deadline has expired.");
        var snapshots = await SnapshotsAsync(attempt.Id, ct);
        Guard.Against(request.Answers is null || request.Answers.Count != snapshots.Count
            || request.Answers.Any(x => x is null)
            || request.Answers.Select(x => x.QuestionId).Distinct().Count() != snapshots.Count,
            "Submit one answer for each question.");
        var byId = request.Answers!.ToDictionary(x => x.QuestionId);
        var answers = new List<StudentAnswer>(snapshots.Count);
        decimal score = 0;
        foreach (var snapshot in snapshots)
        {
            if (!byId.TryGetValue(snapshot.Id, out var answer)) throw new DomainException("Unknown attempt question.");
            var question = JsonSerializer.Deserialize<PublicSnapshot>(snapshot.OptionsSnapshotJson)!;
            var key = JsonSerializer.Deserialize<AnswerKey>(snapshot.AnswerKeySnapshotJson)!;
            score += Grade(snapshot.MaximumScore, question, key, answer);
            answers.Add(new StudentAnswer
            {
                AttemptQuestionId = snapshot.Id, SubmittedAtUtc = now,
                SelectedOptionsJson = JsonSerializer.Serialize(new { answer.OptionId, answer.Value })
            });
        }
        attempt.Submit();
        attempt.Complete(score, now);
        db.AddRange(answers);
        await RecordProgressAsync(userId, courseId, available.LessonStageId, attempt, now, ct);
        // Attempt xmin and unique answer indexes protect the entire SaveChanges transaction.
        await db.SaveChangesAsync(ct);
        return Result(attempt);
    }

    public async Task<ObjectiveResultDto?> FindResultAsync(Guid userId, Guid attemptId, CancellationToken ct)
    {
        var attempt = await db.Set<AssessmentAttempt>().AsNoTracking().SingleOrDefaultAsync(x =>
            x.Id == attemptId && x.StudentId == userId && x.PassingScoreSnapshot != null
            && x.Status == AttemptStatus.Completed, ct);
        return attempt is null ? null : Result(attempt);
    }

    private DateTime UtcNow()
    {
        // PostgreSQL stores microseconds. Normalize before issuing a response that may be replayed.
        var now = clock.GetUtcNow().UtcDateTime;
        return new DateTime(now.Ticks - now.Ticks % TimeSpan.TicksPerMicrosecond, DateTimeKind.Utc);
    }

    private async Task RecordProgressAsync(Guid userId, Guid courseId, Guid stageId, AssessmentAttempt attempt,
        DateTime now, CancellationToken ct)
    {
        var enrollmentId = await db.Set<Enrollment>().Where(x => x.StudentId == userId && x.CourseId == courseId
            && x.Status == "Active").Select(x => x.Id).SingleOrDefaultAsync(ct);
        if (enrollmentId == Guid.Empty) throw new StateConflictException("The enrollment is no longer active.");
        var version = await (from stage in db.Set<LessonStage>().AsNoTracking()
            where stage.Id == stageId
            join lessonVersion in db.Set<LessonVersion>() on stage.LessonVersionId equals lessonVersion.Id
            select lessonVersion).SingleAsync(ct);
        var progress = await db.Set<LessonProgress>().SingleOrDefaultAsync(x => x.EnrollmentId == enrollmentId
            && x.LessonVersionId == version.Id, ct);
        if (progress is null) throw new StateConflictException("Start the lesson before taking its assessment.");
        var stageProgress = await db.Set<StageProgress>().SingleOrDefaultAsync(x => x.LessonProgressId == progress.Id
            && x.LessonStageId == stageId, ct);
        if (stageProgress is null)
        {
            stageProgress = new StageProgress
            {
                LessonProgressId = progress.Id, LessonVersionId = version.Id, LessonStageId = stageId
            };
            db.Add(stageProgress);
        }
        var stageScore = decimal.Round(ObjectiveScoring.Percentage(attempt.Score!.Value, attempt.MaximumScore), 4,
            MidpointRounding.ToZero);
        var stageAttempt = new StageAttempt
        {
            StageProgressId = stageProgress.Id, AttemptNumber = attempt.AttemptNumber, Status = AttemptStatus.Completed,
            Score = stageScore, StartedAtUtc = attempt.StartedAtUtc, CompletedAtUtc = now,
            IdempotencyKey = attempt.IdempotencyKey
        };
        var history = await (from previous in db.Set<StageAttempt>().AsNoTracking()
            join stage in db.Set<StageProgress>() on previous.StageProgressId equals stage.Id
            where stage.LessonProgressId == progress.Id && previous.Status == AttemptStatus.Completed
            select new StageScore(stage.LessonStageId, previous.AttemptNumber, previous.Score, true)).ToListAsync(ct);
        history.Add(new StageScore(stageId, attempt.AttemptNumber, stageScore, true));
        var stages = await db.Set<LessonStage>().AsNoTracking().Where(x => x.LessonVersionId == version.Id).ToListAsync(ct);
        var lessonScore = LessonScoringPolicy.Evaluate(version, stages, history);
        var sameStage = history.Where(x => x.StageId == stageId);
        var selected = version.AttemptSelection == AttemptSelection.Best
            ? sameStage.Max(x => x.Score!.Value)
            : sameStage.OrderByDescending(x => x.AttemptNumber).First().Score!.Value;
        stageProgress.RecordScore(selected, now);
        progress.RecordScore(lessonScore.Score, lessonScore.Passed, now);
        db.AddRange(stageAttempt,
            new AssessmentResult { AssessmentAttemptId = attempt.Id, StageAttemptId = stageAttempt.Id, RecordedAtUtc = now },
            new LearningActivity
            {
                StudentId = userId, EnrollmentId = enrollmentId, ActivityType = "AssessmentSubmitted",
                OccurredAtUtc = now, DurationSeconds = 0
            });
    }

    private async Task<AssessmentEntity?> FindAvailableAsync(Guid userId, Guid courseId, Guid lessonId, Guid assessmentId, CancellationToken ct)
    {
        if (!await db.Set<Enrollment>().AnyAsync(x => x.StudentId == userId && x.CourseId == courseId && x.Status == "Active", ct))
            return null;
        var versionId = await content.FindVersionIdAsync(courseId, lessonId, ct);
        if (versionId is null) return null;
        var started = await (from progress in db.Set<LessonProgress>()
            join enrollment in db.Set<Enrollment>() on progress.EnrollmentId equals enrollment.Id
            where enrollment.StudentId == userId && enrollment.CourseId == courseId
                && enrollment.Status == "Active" && progress.LessonVersionId == versionId
            select progress.Id).AnyAsync(ct);
        if (!started) throw new StateConflictException("Start the lesson before taking its assessment.");
        return await (from assessment in db.Set<AssessmentEntity>().AsNoTracking()
            join stage in db.Set<LessonStage>() on assessment.LessonStageId equals stage.Id
            where assessment.Id == assessmentId && assessment.IsPublished && stage.IsActive && stage.LessonVersionId == versionId
            select assessment).SingleOrDefaultAsync(ct);
    }

    private Task<AssessmentAttempt?> FindByKeyAsync(Guid userId, string key, CancellationToken ct) =>
        db.Set<AssessmentAttempt>().AsNoTracking().SingleOrDefaultAsync(x => x.StudentId == userId && x.IdempotencyKey == key, ct);

    private async Task<ObjectiveAttemptDto> ReplayAsync(AssessmentAttempt attempt, Guid assessmentId, CancellationToken ct)
    {
        if (attempt.AssessmentId != assessmentId || attempt.PassingScoreSnapshot is null)
            throw new StateConflictException("This idempotency key is already in use.");
        return ToAttempt(attempt, await SnapshotsAsync(attempt.Id, ct));
    }

    private Task<List<AssessmentAttemptQuestion>> SnapshotsAsync(Guid attemptId, CancellationToken ct) =>
        db.Set<AssessmentAttemptQuestion>().AsNoTracking().Where(x => x.AssessmentAttemptId == attemptId)
            .OrderBy(x => x.DisplayOrder).ToListAsync(ct);

    private static AssessmentAttemptQuestion Snapshot(Guid attemptId, AssessmentQuestion link, Question question, QuestionOption[] options)
    {
        AnswerKey key;
        ObjectiveOptionDto[] publicOptions;
        if (question.QuestionType == Choice && options.Length >= 2 && options.Count(x => x.IsCorrect) == 1)
        {
            key = new AnswerKey(options.Single(x => x.IsCorrect).Id, null);
            publicOptions = options.Select(x => new ObjectiveOptionDto(x.Id, x.Text)).ToArray();
        }
        else if (question.QuestionType == Boolean)
        {
            using var json = JsonDocument.Parse(question.AnswerKeyJson);
            if (json.RootElement.ValueKind != JsonValueKind.Object || !json.RootElement.TryGetProperty("correctAnswer", out var correct)
                || correct.ValueKind is not (JsonValueKind.True or JsonValueKind.False))
                throw new StateConflictException("A true/false question has an invalid answer key.");
            key = new AnswerKey(null, correct.GetBoolean());
            publicOptions = [];
        }
        else
        {
            throw new StateConflictException("The assessment contains an unsupported question.");
        }
        return new AssessmentAttemptQuestion
        {
            AssessmentAttemptId = attemptId, QuestionId = question.Id, DisplayOrder = link.DisplayOrder,
            PromptSnapshot = question.Prompt, MaximumScore = link.MaximumScore,
            AnswerKeySnapshotJson = JsonSerializer.Serialize(key),
            OptionsSnapshotJson = JsonSerializer.Serialize(new PublicSnapshot(question.QuestionType, publicOptions))
        };
    }

    private static decimal Grade(decimal max, PublicSnapshot question, AnswerKey key, ObjectiveAnswer answer)
    {
        if (question.Kind == Choice && answer.OptionId is { } option && answer.Value is null
            && question.Options.Any(x => x.Id == option) && key.OptionId is { } correct)
            return ObjectiveScoring.ScoreChoice(option, correct, max);
        if (question.Kind == Boolean && answer.Value is { } value && answer.OptionId is null && key.Value is { } correctValue)
            return ObjectiveScoring.ScoreBoolean(value, correctValue, max);
        throw new DomainException("The answer is not valid for this question.");
    }

    private static ObjectiveAttemptDto ToAttempt(AssessmentAttempt attempt, IEnumerable<AssessmentAttemptQuestion> questions) =>
        new(attempt.Id, attempt.AssessmentId, attempt.AttemptNumber, attempt.StartedAtUtc, attempt.DeadlineUtc,
            questions.Select(x =>
            {
                var snapshot = JsonSerializer.Deserialize<PublicSnapshot>(x.OptionsSnapshotJson)!;
                return new ObjectiveQuestionDto(x.Id, snapshot.Kind, x.PromptSnapshot, x.MaximumScore, snapshot.Options);
            }).ToArray());

    private static ObjectiveResultDto Result(AssessmentAttempt attempt)
    {
        var percentage = ObjectiveScoring.Percentage(attempt.Score!.Value, attempt.MaximumScore);
        return new ObjectiveResultDto(attempt.Id, attempt.Score.Value, attempt.MaximumScore,
            decimal.Round(percentage, 2, MidpointRounding.AwayFromZero), attempt.PassingScoreSnapshot!.Value,
            percentage >= attempt.PassingScoreSnapshot.Value, attempt.CompletedAtUtc!.Value);
    }

    private sealed record PublicSnapshot(string Kind, ObjectiveOptionDto[] Options);
    private sealed record AnswerKey(Guid? OptionId, bool? Value);
}
