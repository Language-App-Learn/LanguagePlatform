using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class WordTranslation : PlatformEntity
{
    public required Guid WordSenseId { get; init; }
    public required Guid TargetLanguageId { get; init; }
    public required string Text { get; init; }
}
