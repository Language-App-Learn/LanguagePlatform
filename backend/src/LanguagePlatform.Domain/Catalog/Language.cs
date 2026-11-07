using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed class Language
{
    private Language()
    {
    }

    private Language(Guid id, LanguageCode code, string name, string nativeName, TextDirection textDirection, bool isActive)
    {
        Id = id;
        Code = code;
        Name = name;
        NativeName = nativeName;
        TextDirection = textDirection;
        IsActive = isActive;
    }

    public Guid Id { get; private set; }
    public LanguageCode Code { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string NativeName { get; private set; } = string.Empty;
    public TextDirection TextDirection { get; private set; }
    public bool IsActive { get; private set; }

    public static Language Create(
        string code,
        string name,
        string nativeName,
        TextDirection textDirection,
        bool isActive = true,
        Guid? id = null)
    {
        return new Language(
            id ?? Guid.NewGuid(),
            LanguageCode.Create(code),
            RequiredText(name, nameof(name), 100),
            RequiredText(nativeName, nameof(nativeName), 100),
            textDirection,
            isActive);
    }

    private static string RequiredText(string value, string fieldName, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Trim().Length > maxLength)
        {
            throw new DomainException($"{fieldName} is required and must be at most {maxLength} characters.");
        }

        return value.Trim();
    }
}
