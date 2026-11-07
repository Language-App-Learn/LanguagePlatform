using System.Text.Json;

namespace LanguagePlatform.Application.Identity;

public sealed record AccountDeletionRequest(string Password, string? AuthenticatorCode = null);
public sealed record PersonalEnrollment(Guid Id, Guid CourseId, string Status, DateTime EnrolledAtUtc);
public sealed record PersonalLessonProgress(Guid VersionId, decimal Score, bool Passed, DateTime UpdatedAtUtc);
public sealed record PersonalAttempt(Guid Id, Guid AssessmentId, int AttemptNumber, decimal? Score, decimal MaximumScore,
    DateTime StartedAtUtc, DateTime? CompletedAtUtc);
public sealed record PersonalAnswer(Guid AttemptId, Guid QuestionId, string? Text, JsonElement Answer, DateTime SubmittedAtUtc);
public sealed record AccountDataExport(CurrentAccountDto Account, PreferencesDto? Preferences,
    IReadOnlyList<PersonalEnrollment> Enrollments, IReadOnlyList<PersonalLessonProgress> Progress,
    IReadOnlyList<PersonalAttempt> Attempts, IReadOnlyList<PersonalAnswer> Answers, int? NextOffset);
