using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class QuestionLocalization : PlatformEntity
{
    public required Guid QuestionId { get; init; }
    public required Guid LanguageId { get; init; }
    public required string Prompt { get; init; }
}
