using System.Text.RegularExpressions;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Catalog;

public sealed partial class LearningProgram
{
    private LearningProgram()
    {
    }

    private LearningProgram(Guid id, string code, string name, ProgramType programType, bool isActive)
    {
        Id = id;
        Code = NormalizeCode(code);
        Name = RequiredName(name);
        ProgramType = programType;
        IsActive = isActive;
    }

    public Guid Id { get; private set; }
    public string Code { get; private set; } = string.Empty;
    public string Name { get; private set; } = string.Empty;
    public ProgramType ProgramType { get; private set; }
    public bool IsActive { get; private set; }

    public static LearningProgram Create(
        string code,
        string name,
        ProgramType programType,
        bool isActive = true,
        Guid? id = null) =>
        new(id ?? Guid.NewGuid(), code, name, programType, isActive);

    private static string NormalizeCode(string value)
    {
        var normalized = value?.Trim().ToLowerInvariant() ?? string.Empty;
        if (normalized.Length is < 1 or > 64 || !CodePattern().IsMatch(normalized))
        {
            throw new DomainException("Program code must be a lowercase slug with at most 64 characters.");
        }

        return normalized;
    }

    private static string RequiredName(string value)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Trim().Length > 150)
        {
            throw new DomainException("Program name is required and must be at most 150 characters.");
        }

        return value.Trim();
    }

    [GeneratedRegex("^[a-z0-9]+(?:-[a-z0-9]+)*$", RegexOptions.CultureInvariant)]
    private static partial Regex CodePattern();
}
