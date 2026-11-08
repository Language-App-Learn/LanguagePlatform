using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Tests;

public sealed class ValueObjectTests
{
    [Theory]
    [InlineData("tr", "tr")]
    [InlineData("TR-tr", "tr-TR")]
    [InlineData("zh-Hant", "zh-Hant")]
    public void LanguageCodeNormalizesBcp47StyleCodes(string input, string expected)
    {
        Assert.Equal(expected, LanguageCode.Create(input).Value);
    }

    [Fact]
    public void ProgramTypeAllowsFuturePascalCaseValues()
    {
        var type = ProgramType.Create("AdaptiveImmersion");

        Assert.Equal("AdaptiveImmersion", type.Value);
    }

    [Fact]
    public void LanguageCodeRejectsInvalidValue()
    {
        Assert.Throws<DomainException>(() => LanguageCode.Create("not_a_code"));
    }
}
