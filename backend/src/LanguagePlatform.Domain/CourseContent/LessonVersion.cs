using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class LessonVersion : PlatformEntity
{
    public required Guid LessonId { get; init; }
    public required int VersionNumber { get; init; }
    public required string Title { get; init; }
    public required decimal PassingScore { get; init; }
    public bool UsesFiveStageCurriculum { get; init; }
    public bool WeightsApproved { get; init; }
    public AttemptSelection AttemptSelection { get; init; } = AttemptSelection.Best;
    public PublicationState Status { get; private set; } = PublicationState.Draft;
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime? PublishedAtUtc { get; private set; }
    public uint Version { get; private set; }

    public void SubmitForReview()
    {
        Guard.Against(Status != PublicationState.Draft, "Only a draft can enter review.");
        Guard.Text(Title, 200, nameof(Title));
        Guard.Against(LessonId == Guid.Empty || VersionNumber < 1, "A lesson and positive version are required.");
        Guard.Percentage(PassingScore);
        Status = PublicationState.InReview;
    }

    public void Publish(IReadOnlyCollection<LessonStage> stages, DateTime nowUtc)
    {
        Guard.Against(Status != PublicationState.InReview, "A lesson must be reviewed before publication.");
        Guard.Against(nowUtc.Kind != DateTimeKind.Utc, "Publication time must be UTC.");
        LessonScoringPolicy.ValidateStages(Id, stages);
        if (UsesFiveStageCurriculum)
            FiveStageCurriculum.ValidatePublication(PassingScore, WeightsApproved, stages);
        Status = PublicationState.Published;
        PublishedAtUtc = nowUtc;
    }
}
