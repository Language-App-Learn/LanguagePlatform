using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Dictionary;

public sealed class StudentSavedWord : PlatformEntity
{
    public required Guid StudentId { get; init; }
    public required Guid DictionaryEntryId { get; init; }
    public required DateTime SavedAtUtc { get; init; }
    public string? Note { get; init; }
    public bool IsFavorite { get; init; } = true;
}

