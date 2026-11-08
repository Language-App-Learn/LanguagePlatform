using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Application.Catalog;

public sealed record CourseQuery(
    string? Source = null, string? Target = null, Guid? LearningPathId = null,
    Guid? ProgramId = null, string? Locale = null, string? After = null, int Limit = 20)
{
    public CourseQuery Validate()
    {
        Guard.Against(Limit is < 1 or > 100, "Limit must be between 1 and 100.");
        Guard.Against(LearningPathId == Guid.Empty || ProgramId == Guid.Empty, "Identifiers must be non-empty.");
        Guard.Against(After is { Length: > 120 or 0 }, "Invalid course cursor.");
        return this with
        {
            Source = Normalize(Source),
            Target = Normalize(Target),
            Locale = Normalize(Locale)
        };
    }

    private static string? Normalize(string? code) => code is null ? null : LanguageCode.Create(code).Value;
}

public sealed record CoursePage(IReadOnlyList<CourseDto> Items, string? NextCursor);
public sealed record CourseTranslationDto(string Locale, string Title, string? Description);
public sealed record CourseLevelDto(Guid Id, string Code, int Order);
