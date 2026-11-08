using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Tests;

public sealed class LearningPathTests
{
    [Fact]
    public void CreateThrowsWhenSourceAndTargetAreSame()
    {
        var languageId = Guid.NewGuid();

        var exception = Assert.Throws<DomainException>(() =>
            LearningPath.Create(languageId, languageId));

        Assert.Equal("Source and target languages must be different.", exception.Message);
    }

    [Fact]
    public void CreatePreservesAValidDirection()
    {
        var sourceId = Guid.NewGuid();
        var targetId = Guid.NewGuid();

        var path = LearningPath.Create(sourceId, targetId);

        Assert.Equal(sourceId, path.SourceLanguageId);
        Assert.Equal(targetId, path.TargetLanguageId);
    }
}
