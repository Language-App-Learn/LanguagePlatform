using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Application.CourseContent;

public sealed record CreateCurriculumCourse(string Slug, string Title, string? Description);
public sealed record DraftChoice(string Text, bool IsCorrect);
public sealed record DraftQuestion(string Kind, string Prompt, IReadOnlyList<DraftChoice>? Options, bool? CorrectValue);
public sealed record DraftStage(string Kind, decimal? Weight, int MaximumAttempts, string? ArabicText,
    string? TurkishText, IReadOnlyList<DraftQuestion>? Questions);
public sealed record CreateCurriculumVersion(string Title, bool ApproveWeights, AttemptSelection AttemptSelection,
    IReadOnlyList<DraftStage> Stages);
public sealed record CurriculumLevelDto(Guid Id, string Code, int Order, int Capacity);
public sealed record CurriculumCourseDto(Guid CourseId, IReadOnlyList<CurriculumLevelDto> Levels);
public sealed record CurriculumSlotDto(int Position, Guid? LessonId, Guid? PublishedVersionId, string? Title, Guid? DraftVersionId = null);
public sealed record CurriculumDraftDto(Guid LessonId, Guid VersionId, int VersionNumber, uint Revision, bool WeightsApproved);
public sealed record ReviewCurriculumVersion(uint ExpectedVersion);
public sealed record StageStateDto(Guid Id, string Kind, int Order, string Status, decimal? Score, int Attempts);
public sealed record CurriculumProgressDto(Guid VersionId, IReadOnlyList<StageStateDto> Stages,
    decimal? FinalScore, decimal PassingScore, bool Passed, Guid? NextLessonId);
