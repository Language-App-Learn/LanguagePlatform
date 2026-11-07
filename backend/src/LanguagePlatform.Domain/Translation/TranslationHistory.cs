using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Translation;

public sealed class TranslationHistory : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid SourceLanguageId { get; init; }
    public required Guid TargetLanguageId { get; init; }
    public required string SourceText { get; init; }
    public required string TranslatedText { get; init; }
    public string? Context { get; init; }
    public required string ProviderModel { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
}
