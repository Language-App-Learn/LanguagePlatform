using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.StudentProgress;

public sealed class Enrollment : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid CourseId { get; init; }
    public required DateTime EnrolledAtUtc { get; init; }
    public required string Status { get; init; }
    public DateTime? CompletedAtUtc { get; init; }
    public uint Version { get; private set; }
}

