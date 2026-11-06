namespace LanguagePlatform.Application.Assessment;

public sealed record StartObjectiveAttempt(string IdempotencyKey);
public sealed record ObjectiveOptionDto(Guid Id, string Text);
public sealed record ObjectiveQuestionDto(Guid Id, string Kind, string Prompt, decimal MaximumScore,
    IReadOnlyList<ObjectiveOptionDto> Options);
public sealed record ObjectiveAttemptDto(Guid Id, Guid AssessmentId, int AttemptNumber, DateTime StartedAtUtc,
    DateTime? DeadlineUtc, IReadOnlyList<ObjectiveQuestionDto> Questions);
public sealed record ObjectiveAnswer(Guid QuestionId, Guid? OptionId, bool? Value);
public sealed record SubmitObjectiveAttempt(IReadOnlyList<ObjectiveAnswer> Answers);
public sealed record ObjectiveResultDto(Guid AttemptId, decimal Score, decimal MaximumScore, decimal Percentage,
    decimal PassingScore, bool Passed, DateTime CompletedAtUtc);
