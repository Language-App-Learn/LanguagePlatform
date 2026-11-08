using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Tests;

public sealed class ObjectiveScoringTests
{
    [Fact]
    public void ScoresUseStoredWeightsAndKeys()
    {
        var correct = Guid.NewGuid();
        var score = ObjectiveScoring.ScoreChoice(correct, correct, 3)
            + ObjectiveScoring.ScoreBoolean(false, true, 2);
        Assert.Equal(3, score);
        Assert.Equal(60, ObjectiveScoring.Percentage(score, 5));
    }

    [Fact]
    public void InvalidMaximumCannotProduceAPercentage()
    {
        Assert.Throws<DomainException>(() => ObjectiveScoring.Percentage(1, 0));
    }
}
