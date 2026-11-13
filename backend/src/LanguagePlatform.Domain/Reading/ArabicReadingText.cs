using System.Globalization;
using System.Text;

namespace LanguagePlatform.Domain.Reading;

public static class ArabicReadingText
{
    public static bool ContainsArabic(string text) => text.Normalize(NormalizationForm.FormKC).EnumerateRunes()
        .Any(rune => rune.Value is (>= 0x0600 and <= 0x06FF) or (>= 0x0750 and <= 0x077F)
            or (>= 0x0870 and <= 0x089F) or (>= 0x08A0 and <= 0x08FF)
            && Rune.IsLetter(rune) && rune.Value != 0x0640);

    public static bool Matches(string reference, string transcript)
    {
        var expected = Tokens(reference);
        return expected.Length > 0 && expected.SequenceEqual(Tokens(transcript), StringComparer.Ordinal);
    }

    private static string[] Tokens(string text)
    {
        var normalized = new StringBuilder(text.Length);
        foreach (var rune in text.Normalize(NormalizationForm.FormKC).EnumerateRunes())
        {
            var category = Rune.GetUnicodeCategory(rune);
            if (category is UnicodeCategory.NonSpacingMark or UnicodeCategory.SpacingCombiningMark
                or UnicodeCategory.EnclosingMark or UnicodeCategory.Format || rune.Value == 0x0640)
                continue;

            if (rune.Value == 0x0671)
                normalized.Append('\u0627'); // Alef wasla is commonly transcribed as bare alef.
            else if (Rune.IsLetterOrDigit(rune))
                normalized.Append(rune.ToString());
            else
                normalized.Append(' ');
        }
        return normalized.ToString().Split(' ', StringSplitOptions.RemoveEmptyEntries);
    }
}
