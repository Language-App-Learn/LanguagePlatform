using System.Text.RegularExpressions;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public readonly partial record struct ProgramType
{
    public static readonly ProgramType ModernLanguage = Create("ModernLanguage");
    public static readonly ProgramType ExamPreparation = Create("ExamPreparation");
    public static readonly ProgramType ReligiousReading = Create("ReligiousReading");
    public static readonly ProgramType Conversation = Create("Conversation");

    private ProgramType(string value) => Value = value;

    public string Value { get; }

    public static ProgramType Create(string value)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Length > 64 || !ProgramTypePattern().IsMatch(value))
        {
            throw new DomainException("Program type must be a 1-64 character PascalCase identifier.");
        }

        return new ProgramType(value);
    }

    public override string ToString() => Value;

    [GeneratedRegex("^[A-Z][A-Za-z0-9]*$", RegexOptions.CultureInvariant)]
    private static partial Regex ProgramTypePattern();
}
