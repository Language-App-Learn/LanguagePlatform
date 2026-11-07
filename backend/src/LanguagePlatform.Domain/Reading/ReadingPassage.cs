using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingPassage : PlatformEntity
{
    public required Guid ReadingMaterialId { get; init; }
    public required int Sequence { get; init; }
    public required string OriginalText { get; init; }
    public int? PageNumber { get; init; }
}
