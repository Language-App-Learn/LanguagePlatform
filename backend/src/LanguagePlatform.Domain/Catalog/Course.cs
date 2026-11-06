using System.Text.RegularExpressions;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed partial class Course
{
    private Course()
    {
    }

    private Course(
        Guid id,
        Guid learningPathId,
        Guid learningProgramId,
        string slug,
        string title,
        string? description,
        CourseStatus status)
    {
        Guard.Against(learningPathId == Guid.Empty || learningProgramId == Guid.Empty, "Course path and program are required.");
        Guard.Against(!Enum.IsDefined(status), "Invalid course status.");
        Id = id;
        LearningPathId = learningPathId;
        LearningProgramId = learningProgramId;
        Slug = NormalizeSlug(slug);
        Title = RequiredTitle(title);
        Description = OptionalDescription(description);
        Status = status;
    }

    public Guid Id { get; private set; }
    public Guid LearningPathId { get; private set; }
    public Guid LearningProgramId { get; private set; }
    public string Slug { get; private set; } = string.Empty;
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public CourseStatus Status { get; private set; }
    public LearningPath LearningPath { get; private set; } = null!;
    public LearningProgram LearningProgram { get; private set; } = null!;

    public void SubmitForReview()
    {
        Guard.Against(Status != CourseStatus.Draft, "Only a draft course can enter review.");
        Status = CourseStatus.InReview;
    }

    public void Publish()
    {
        Guard.Against(Status != CourseStatus.InReview, "Only reviewed courses can be published.");
        Status = CourseStatus.Published;
    }

    public void Archive() => Status = CourseStatus.Archived;

    public static Course Create(
        Guid learningPathId,
        Guid learningProgramId,
        string slug,
        string title,
        string? description = null,
        CourseStatus status = CourseStatus.Draft,
        Guid? id = null) =>
        new(id ?? Guid.NewGuid(), learningPathId, learningProgramId, slug, title, description, status);

    public static Course Create(
        LearningPath learningPath,
        LearningProgram learningProgram,
        string slug,
        string title,
        string? description = null,
        CourseStatus status = CourseStatus.Draft,
        Guid? id = null)
    {
        ArgumentNullException.ThrowIfNull(learningPath);
        ArgumentNullException.ThrowIfNull(learningProgram);

        var course = new Course(
            id ?? Guid.NewGuid(),
            learningPath.Id,
            learningProgram.Id,
            slug,
            title,
            description,
            status)
        {
            LearningPath = learningPath,
            LearningProgram = learningProgram
        };

        return course;
    }

    private static string NormalizeSlug(string value)
    {
        var normalized = value?.Trim().ToLowerInvariant() ?? string.Empty;
        if (normalized.Length is < 1 or > 120 || !SlugPattern().IsMatch(normalized))
        {
            throw new DomainException("Course slug must be a lowercase slug with at most 120 characters.");
        }

        return normalized;
    }

    private static string RequiredTitle(string value)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Trim().Length > 200)
        {
            throw new DomainException("Course title is required and must be at most 200 characters.");
        }

        return value.Trim();
    }

    private static string? OptionalDescription(string? value)
    {
        var trimmed = value?.Trim();
        if (trimmed?.Length > 2_000)
        {
            throw new DomainException("Course description must be at most 2000 characters.");
        }

        return string.IsNullOrEmpty(trimmed) ? null : trimmed;
    }

    [GeneratedRegex("^[a-z0-9]+(?:-[a-z0-9]+)*$", RegexOptions.CultureInvariant)]
    private static partial Regex SlugPattern();
}
