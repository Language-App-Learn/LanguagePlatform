using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.CourseContent;

public sealed class LessonPrerequisite : PlatformEntity
{
    public required Guid LessonId { get; init; }
    public required Guid RequiredLessonId { get; init; }
}

