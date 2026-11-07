using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class QuestionBank : PlatformEntity
{
    public required Guid LanguageId { get; init; }
    public required Guid OwnerId { get; init; }
    public required string Name { get; init; }
}
