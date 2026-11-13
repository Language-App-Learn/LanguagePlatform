using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Domain.Tests;

public sealed class ArabicReadingTextTests
{
    [Theory]
    [InlineData("  ٱلسَّلَامُ ، عَلَيْكُمْ  ", "السلام عليكم", true)]
    [InlineData("ﺍﻟﺴﻼﻡ عَلَيْكُمْ", "الســلام عليكم", true)]
    [InlineData("سَلَامٌ عَلَيْكُمْ", "سلام", false)]
    [InlineData("سَلَامٌ عَلَيْكُمْ", "سلام سلام عليكم", false)]
    [InlineData("سَلَامٌ عَلَيْكُمْ", "سلام عليكم جدا", false)]
    [InlineData("سَلَامٌ عَلَيْكُمْ", "عليكم سلام", false)]
    [InlineData("سَلَامٌ عَلَيْكُمْ", "سلام إليكم", false)]
    [InlineData("إِنَّ", "ان", false)]
    [InlineData("سَلَامٌ", "", false)]
    public void ComparesEveryWordInOrder(string reference, string transcript, bool expected) =>
        Assert.Equal(expected, ArabicReadingText.Matches(reference, transcript));

    [Theory]
    [InlineData("ُّـ١", false)]
    [InlineData("ܐܠܗܐ", false)]
    [InlineData("𞸀", true)]
    [InlineData("ﺍ", true)]
    public void DetectsArabicLetters(string value, bool expected) =>
        Assert.Equal(expected, ArabicReadingText.ContainsArabic(value));
}
