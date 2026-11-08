using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class LanguagePlatformDbContextFactory : IDesignTimeDbContextFactory<LanguagePlatformDbContext>
{
    public LanguagePlatformDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("LANGUAGEPLATFORM_DESIGN_CONNECTION")
            ?? "Host=localhost;Port=5432;Database=language_platform_dev;Username=postgres;Include Error Detail=false";

        var options = new DbContextOptionsBuilder<LanguagePlatformDbContext>()
            .UseNpgsql(connectionString, npgsql =>
                npgsql.MigrationsAssembly(typeof(LanguagePlatformDbContext).Assembly.FullName))
            .Options;

        return new LanguagePlatformDbContext(options);
    }
}
