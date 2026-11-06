namespace LanguagePlatform.Domain.Common;

public static class Guard
{
    public static void Against(bool condition, string message)
    {
        if (condition)
        {
            throw new DomainException(message);
        }
    }

    public static string Text(string value, int maxLength, string field)
    {
        Against(string.IsNullOrWhiteSpace(value) || value.Length > maxLength, $"{field} is required (maximum {maxLength} characters).");
        return value.Trim();
    }

    public static decimal Percentage(decimal value)
    {
        Against(value is < 0 or > 100, "Score must be between 0 and 100.");
        return value;
    }
}
