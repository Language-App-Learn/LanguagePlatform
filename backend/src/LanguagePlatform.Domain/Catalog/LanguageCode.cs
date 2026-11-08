using System.Text.RegularExpressions;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public readonly partial record struct LanguageCode
{
    public const int MaxLength = 35;

    private LanguageCode(string value) => Value = value;

    public string Value { get; }

    public static LanguageCode Create(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new DomainException("Language code is required.");
        }

        var trimmed = value.Trim();
        if (trimmed.Length > MaxLength || !LanguageCodePattern().IsMatch(trimmed))
        {
            throw new DomainException("Language code must be a valid ISO/BCP-47 style code.");
        }

        var parts = trimmed.Split('-');
        parts[0] = parts[0].ToLowerInvariant();

        for (var index = 1; index < parts.Length; index++)
        {
            parts[index] = parts[index].Length switch
            {
                2 when parts[index].All(char.IsLetter) => parts[index].ToUpperInvariant(),
                4 when parts[index].All(char.IsLetter) =>
                    char.ToUpperInvariant(parts[index][0]) + parts[index][1..].ToLowerInvariant(),
                _ => parts[index].ToLowerInvariant()
            };
        }

        return new LanguageCode(string.Join('-', parts));
    }

    public override string ToString() => Value;

    [GeneratedRegex("^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$", RegexOptions.CultureInvariant)]
    private static partial Regex LanguageCodePattern();
}
