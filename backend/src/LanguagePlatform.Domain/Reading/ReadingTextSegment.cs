using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingTextSegment : PlatformEntity
{
    public required Guid ReadingPassageId { get; init; }
    public required int Sequence { get; init; }
    public required string Text { get; init; }
    public required int StartOffset { get; init; }
    public required int Length { get; init; }
    public required int AlignmentSchemaVersion { get; init; }
    public required string AlignmentJson { get; init; }
}

