using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Assessment;

public sealed class Question : PlatformEntity
{
    public required Guid QuestionBankId { get; init; }
    public required string Code { get; init; }
    public required int VersionNumber { get; init; }
    public required string QuestionType { get; init; }
    public required string Prompt { get; init; }
    public required string AnswerKeyJson { get; init; }
    public bool IsArchived { get; init; }
}

