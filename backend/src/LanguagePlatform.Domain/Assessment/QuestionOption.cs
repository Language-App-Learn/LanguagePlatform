using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class QuestionOption : PlatformEntity
{
    public required Guid QuestionId { get; init; }
    public required int DisplayOrder { get; init; }
    public required string Text { get; init; }
    public bool IsCorrect { get; init; }
}
