using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class LearningPath
{
    private LearningPath()
    {
    }

    private LearningPath(Guid id, Guid sourceLanguageId, Guid targetLanguageId, bool isActive)
    {
        if (sourceLanguageId == targetLanguageId)
        {
            throw new DomainException("Source and target languages must be different.");
        }

        Id = id;
        SourceLanguageId = sourceLanguageId;
        TargetLanguageId = targetLanguageId;
        IsActive = isActive;
    }

    public Guid Id { get; private set; }
    public Guid SourceLanguageId { get; private set; }
    public Guid TargetLanguageId { get; private set; }
    public bool IsActive { get; private set; }
    public Language SourceLanguage { get; private set; } = null!;
    public Language TargetLanguage { get; private set; } = null!;

    public static LearningPath Create(
        Guid sourceLanguageId,
        Guid targetLanguageId,
        bool isActive = true,
        Guid? id = null) =>
        new(id ?? Guid.NewGuid(), sourceLanguageId, targetLanguageId, isActive);

    public static LearningPath Create(
        Language sourceLanguage,
        Language targetLanguage,
        bool isActive = true,
        Guid? id = null)
    {
        ArgumentNullException.ThrowIfNull(sourceLanguage);
        ArgumentNullException.ThrowIfNull(targetLanguage);

        var path = new LearningPath(id ?? Guid.NewGuid(), sourceLanguage.Id, targetLanguage.Id, isActive)
        {
            SourceLanguage = sourceLanguage,
            TargetLanguage = targetLanguage
        };

        return path;
    }
}
