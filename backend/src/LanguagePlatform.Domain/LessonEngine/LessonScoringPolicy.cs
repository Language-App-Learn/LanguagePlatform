using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Domain.LessonEngine;

public sealed record StageScore(Guid StageId, int AttemptNumber, decimal? Score, bool Completed);
public sealed record LessonScore(decimal? Score, bool Passed, IReadOnlyList<Guid> BlockingStages);

public static class LessonScoringPolicy
{
    public static void ValidateStages(Guid versionId, IReadOnlyCollection<LessonStage> stages)
    {
        Guard.Against(stages.Count == 0 || stages.Any(x => x.LessonVersionId != versionId),
            "Stages must belong to this lesson version.");
        Guard.Against(stages.Select(x => x.Id).Distinct().Count() != stages.Count
            || stages.Select(x => x.DisplayOrder).Distinct().Count() != stages.Count, "Stages and order must be unique.");
        foreach (var stage in stages)
        {
            Guard.Text(stage.StageType, 64, nameof(stage.StageType));
            Guard.Percentage(stage.Weight);
            Guard.Percentage(stage.MinimumScore);
            Guard.Against(stage.MaximumAttempts < 1 || stage.DisplayOrder < 1, "Invalid stage attempt limit or order.");
            Guard.Against(stage.IsRequired && !stage.IsActive, "A required stage cannot be disabled.");
        }
        Guard.Against(stages.Where(x => x.IsActive).Sum(x => x.Weight) != 100,
            "Active stage weights must total 100 before publication.");
    }

    public static LessonScore Evaluate(LessonVersion version, IReadOnlyCollection<LessonStage> stages, IReadOnlyCollection<StageScore> attempts)
    {
        Guard.Against(version.Status != PublicationState.Published, "Only published lessons can be scored.");
        ValidateStages(version.Id, stages);
        if (version.UsesFiveStageCurriculum)
            FiveStageCurriculum.ValidatePublication(version.PassingScore, version.WeightsApproved, stages);
        Guard.Against(attempts.Any(x => !stages.Any(s => s.Id == x.StageId)), "Unknown stage attempt.");
        Guard.Against(attempts.GroupBy(x => new { x.StageId, x.AttemptNumber }).Any(x => x.Count() > 1), "Duplicate stage attempt.");
        var blockers = new List<Guid>();
        var contributions = new List<(decimal Score, decimal Weight)>(stages.Count);
        foreach (var stage in stages.Where(x => x.IsActive))
        {
            var candidates = attempts.Where(x => x.StageId == stage.Id).ToArray();
            foreach (var attempt in candidates)
            {
                Guard.Against(attempt.AttemptNumber < 1 || attempt.AttemptNumber > stage.MaximumAttempts, "Attempt limit exceeded.");
                Guard.Against(attempt.Completed && !attempt.Score.HasValue, "Completed attempts require a score.");
                if (attempt.Score.HasValue) Guard.Percentage(attempt.Score.Value);
            }
            var completed = candidates.Where(x => x.Completed);
            var chosen = version.AttemptSelection == AttemptSelection.Best
                ? completed.OrderByDescending(x => x.Score).ThenByDescending(x => x.AttemptNumber).FirstOrDefault()
                : completed.OrderByDescending(x => x.AttemptNumber).FirstOrDefault();
            var score = chosen?.Score ?? 0;
            contributions.Add((score, stage.Weight));
            if ((stage.IsRequired && chosen == null) || (chosen != null && score < stage.MinimumScore))
                blockers.Add(stage.Id);
        }
        if (version.UsesFiveStageCurriculum && blockers.Count != 0)
            return new LessonScore(null, false, blockers);
        var total = contributions.Sum(x => x.Score * x.Weight / 100m);
        // The new curriculum truncates display precision so a failing score never displays as 60.
        var displayScore = decimal.Round(total, 2,
            version.UsesFiveStageCurriculum ? MidpointRounding.ToZero : MidpointRounding.AwayFromZero);
        var decisionScore = version.UsesFiveStageCurriculum ? total : displayScore;
        return new LessonScore(displayScore, decisionScore >= version.PassingScore && blockers.Count == 0, blockers);
    }

    public static bool CanUnlock(IEnumerable<Guid> prerequisites, IReadOnlySet<Guid> passedLessons) =>
        prerequisites.All(passedLessons.Contains);
}
