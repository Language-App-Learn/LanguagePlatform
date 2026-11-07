using System.Text.Json;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Identity;

public sealed class AccountDataExportService(LanguagePlatformDbContext db, MobileAccountService accounts,
    AccountPreferencesService preferences)
{
    public async Task<AccountDataExport> GetAsync(Guid userId, int offset, int limit, CancellationToken ct)
    {
        Guard.Against(offset is < 0 or > 100000 || limit is < 1 or > 50, "Invalid export page.");
        var account = await accounts.GetAccountAsync(userId, ct) ?? throw new ResourceNotFoundException();
        var saved = await preferences.FindAsync(userId, ct);
        var owned = db.Set<Enrollment>().AsNoTracking().Where(x => x.StudentId == userId);
        var enrollments = await owned.OrderBy(x => x.Id).Skip(offset).Take(limit + 1)
            .Select(x => new PersonalEnrollment(x.Id, x.CourseId, x.Status, x.EnrolledAtUtc)).ToListAsync(ct);
        var progress = await db.Set<LessonProgress>().AsNoTracking().Where(x => owned.Any(e => e.Id == x.EnrollmentId))
            .OrderBy(x => x.Id).Skip(offset).Take(limit + 1)
            .Select(x => new PersonalLessonProgress(x.LessonVersionId, x.Score, x.IsPassed, x.UpdatedAtUtc)).ToListAsync(ct);
        var attemptQuery = db.Set<AssessmentAttempt>().AsNoTracking().Where(x => x.StudentId == userId);
        var attempts = await attemptQuery.OrderBy(x => x.Id).Skip(offset).Take(limit + 1)
            .Select(x => new PersonalAttempt(x.Id, x.AssessmentId, x.AttemptNumber, x.Score, x.MaximumScore,
                x.StartedAtUtc, x.CompletedAtUtc)).ToListAsync(ct);
        var answers = await (from attempt in attemptQuery
            join question in db.Set<AssessmentAttemptQuestion>() on attempt.Id equals question.AssessmentAttemptId
            join answer in db.Set<StudentAnswer>() on question.Id equals answer.AttemptQuestionId
            orderby answer.Id
            select new { AttemptId = attempt.Id, QuestionId = question.Id, answer.AnswerText, answer.SelectedOptionsJson,
                answer.SubmittedAtUtc }).Skip(offset).Take(limit + 1).ToListAsync(ct);
        var more = enrollments.Count > limit || progress.Count > limit || attempts.Count > limit || answers.Count > limit;
        return new AccountDataExport(account, saved, enrollments.Take(limit).ToArray(), progress.Take(limit).ToArray(),
            attempts.Take(limit).ToArray(), answers.Take(limit).Select(x => new PersonalAnswer(x.AttemptId, x.QuestionId,
                x.AnswerText, JsonSerializer.Deserialize<JsonElement>(x.SelectedOptionsJson), x.SubmittedAtUtc)).ToArray(),
            more ? offset + limit : null);
    }
}
