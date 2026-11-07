using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class ModelContractTests
{
    [Fact]
    public void ModelBuildsPostgreSqlDdlWithRestrictiveRelationships()
    {
        using var context = NewContext();
        var sql = context.Database.GenerateCreateScript();
        Assert.Contains("identity_users", sql, StringComparison.Ordinal);
        Assert.Contains("media_assets", sql, StringComparison.Ordinal);
        Assert.All(context.Model.GetEntityTypes().SelectMany(x => x.GetForeignKeys()),
            fk => Assert.Equal(DeleteBehavior.Restrict, fk.DeleteBehavior));
        Assert.All(context.Model.GetEntityTypes(), entity => Assert.NotNull(entity.FindPrimaryKey()));
    }

    internal static LanguagePlatformDbContext NewContext() => new(
        new DbContextOptionsBuilder<LanguagePlatformDbContext>()
            .UseNpgsql("Host=localhost;Database=language_platform_test;Username=unused").Options);
}
