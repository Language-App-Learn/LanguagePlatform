using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.LessonEngine;

public static class FiveStageCurriculum
{
    public const decimal PassingScore = 60m;
    public const int SlotsPerLevel = 20;
    public static IReadOnlyList<string> Levels { get; } = Array.AsReadOnly(new[] { "A1", "A2", "B1", "B2", "C1", "C2" });
    public static IReadOnlyList<string> Stages { get; } = Array.AsReadOnly(new[]
    {
        "reading", "speaking", "listening", "writing", "translation"
    });

    public static void ValidatePublication(decimal passingScore, bool weightsApproved, IReadOnlyCollection<LessonStage> stages)
    {
        Guard.Against(passingScore != PassingScore, "The five-stage passing threshold is 60.");
        Guard.Against(!weightsApproved, "Approve all five explicit weights before publication.");
        var ordered = stages.OrderBy(stage => stage.DisplayOrder).ToArray();
        Guard.Against(ordered.Length != Stages.Count, "The lesson must contain exactly five stages.");
        for (var index = 0; index < ordered.Length; index++)
        {
            var stage = ordered[index];
            Guard.Against(stage.DisplayOrder != index + 1 || stage.StageType != Stages[index] ||
                !stage.IsRequired || !stage.IsActive, $"Stage {index + 1} must be active, required and of type {Stages[index]}.");
            Guard.Against(stage.MinimumScore != 0, "This curriculum does not set per-stage passing thresholds.");
            Guard.Against(decimal.Round(stage.Weight, 4) != stage.Weight, "A weight may have at most four decimal places.");
        }
    }
}
