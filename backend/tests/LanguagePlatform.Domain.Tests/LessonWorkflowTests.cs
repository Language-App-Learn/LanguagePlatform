using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Domain.Tests;

public sealed class LessonWorkflowTests
{
    [Fact]
    public void RequiredStageBlocksPassingEvenWhenWeightedScoreIsHigh()
    {
        var version = NewVersion();
        var stages = new[] { Stage(version.Id, 1, 80, false), Stage(version.Id, 2, 20, true) };
        version.SubmitForReview();
        version.Publish(stages, DateTime.UtcNow);
        var result = LessonScoringPolicy.Evaluate(version, stages, [new(stages[0].Id, 1, 100, true)]);
        Assert.Equal(80, result.Score);
        Assert.False(result.Passed);
        Assert.Contains(stages[1].Id, result.BlockingStages);
    }

    [Theory]
    [InlineData(99)]
    [InlineData(101)]
    public void PublicationRejectsInconsistentWeights(int weight)
    {
        var version = NewVersion();
        version.SubmitForReview();
        Assert.Throws<DomainException>(() => version.Publish([Stage(version.Id, 1, weight, true)], DateTime.UtcNow));
        Assert.Equal(PublicationState.InReview, version.Status);
    }

    [Theory]
    [InlineData(AttemptSelection.Best, 90, true)]
    [InlineData(AttemptSelection.Latest, 40, false)]
    public void AttemptSelectionIsDeterministic(AttemptSelection policy, decimal expected, bool passed)
    {
        var version = NewVersion(policy);
        var stage = Stage(version.Id, 1, 100, true);
        version.SubmitForReview();
        version.Publish([stage], DateTime.UtcNow);
        var result = LessonScoringPolicy.Evaluate(version, [stage],
            [new(stage.Id, 1, 90, true), new(stage.Id, 2, 40, true)]);
        Assert.Equal(expected, result.Score);
        Assert.Equal(passed, result.Passed);
    }

    [Fact]
    public void StageMinimumAndAttemptLimitsAreEnforced()
    {
        var version = NewVersion();
        var stage = Stage(version.Id, 1, 100, true, 80);
        version.SubmitForReview();
        version.Publish([stage], DateTime.UtcNow);
        Assert.False(LessonScoringPolicy.Evaluate(version, [stage], [new(stage.Id, 1, 75, true)]).Passed);
        Assert.Throws<DomainException>(() => LessonScoringPolicy.Evaluate(version, [stage], [new(stage.Id, 4, 100, true)]));
        Assert.Throws<DomainException>(() => version.Publish([stage], DateTime.UtcNow));
    }

    [Fact]
    public void PrerequisitesMustAllBePassed()
    {
        var first = Guid.NewGuid();
        var second = Guid.NewGuid();
        Assert.False(LessonScoringPolicy.CanUnlock([first, second], new HashSet<Guid> { first }));
        Assert.True(LessonScoringPolicy.CanUnlock([first, second], new HashSet<Guid> { first, second }));
    }

    [Theory]
    [InlineData(59.9999, 59.99, false)]
    [InlineData(60, 60, true)]
    [InlineData(61, 61, true)]
    public void FiveStageLessonOnlyScoresAfterAllStagesFinish(decimal score, decimal expected, bool passed)
    {
        var version = FiveStageVersion(true);
        var stages = FiveStages(version.Id);
        version.SubmitForReview();
        version.Publish(stages, DateTime.UtcNow);
        var attempts = stages.Select(x => new StageScore(x.Id, 1, score, true)).ToArray();
        var partial = LessonScoringPolicy.Evaluate(version, stages, attempts[..^1]);
        Assert.Null(partial.Score);
        Assert.False(partial.Passed);
        Assert.Equal(stages[^1].Id, Assert.Single(partial.BlockingStages));
        var complete = LessonScoringPolicy.Evaluate(version, stages, attempts);
        Assert.Equal(expected, complete.Score);
        Assert.Equal(passed, complete.Passed);
    }

    [Fact]
    public void FiveStagePublicationRequiresApprovedWeightsAndCorrectStageOrder()
    {
        var unapproved = FiveStageVersion(false);
        unapproved.SubmitForReview();
        Assert.Throws<DomainException>(() => unapproved.Publish(FiveStages(unapproved.Id), DateTime.UtcNow));
        var approved = FiveStageVersion(true);
        var stages = FiveStages(approved.Id);
        stages[0] = Stage(approved.Id, 1, 20, true, kind: "speaking");
        approved.SubmitForReview();
        Assert.Throws<DomainException>(() => approved.Publish(stages, DateTime.UtcNow));
    }

    [Fact]
    public void AssessmentSubmissionAndCompletionAreSingleTransitions()
    {
        var attempt = new Domain.Assessment.AssessmentAttempt
        {
            StudentId = Guid.NewGuid(), AssessmentId = Guid.NewGuid(), MaximumScore = 20,
            AttemptNumber = 1, IdempotencyKey = "submit-1"
        };
        Assert.Throws<DomainException>(() => attempt.Complete(10, DateTime.UtcNow));
        attempt.Submit();
        Assert.Equal(AttemptStatus.PendingEvaluation, attempt.Status);
        Assert.Throws<DomainException>(attempt.Submit);
        Assert.Throws<DomainException>(() => attempt.Complete(21, DateTime.UtcNow));
        attempt.Complete(15, DateTime.UtcNow);
        Assert.Equal(15, attempt.Score);
        Assert.Throws<DomainException>(() => attempt.Complete(15, DateTime.UtcNow));
    }

    private static LessonVersion NewVersion(AttemptSelection selection = AttemptSelection.Best) => new()
    {
        LessonId = Guid.NewGuid(), VersionNumber = 1, Title = "Tanışma",
        PassingScore = 60, AttemptSelection = selection
    };

    private static LessonVersion FiveStageVersion(bool weightsApproved) => new()
    {
        LessonId = Guid.NewGuid(), VersionNumber = 1, Title = "Tanışma", PassingScore = 60,
        AttemptSelection = AttemptSelection.Best, UsesFiveStageCurriculum = true, WeightsApproved = weightsApproved
    };

    private static LessonStage[] FiveStages(Guid versionId) => FiveStageCurriculum.Stages
        .Select((kind, index) => Stage(versionId, index + 1, 20, true, kind: kind)).ToArray();

    private static LessonStage Stage(Guid version, int order, decimal weight, bool required, decimal minimum = 0,
        string kind = "Reading") => new()
    {
        LessonVersionId = version, DisplayOrder = order, StageType = kind, Weight = weight,
        IsRequired = required, MinimumScore = minimum, MaximumAttempts = 3, EstimatedDurationSeconds = 60,
        SettingsSchemaVersion = 1, SettingsJson = "{}", IsActive = true
    };
}
