using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public static class ObjectiveScoring
{
    public static decimal ScoreChoice(Guid selected, Guid correct, decimal maximum) =>
        selected == correct ? maximum : 0;

    public static decimal ScoreBoolean(bool selected, bool correct, decimal maximum) =>
        selected == correct ? maximum : 0;

    public static decimal Percentage(decimal score, decimal maximum)
    {
        Guard.Against(maximum <= 0 || score < 0 || score > maximum, "Invalid score range.");
        return score * 100 / maximum;
    }
}
