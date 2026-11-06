using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlPersistenceTests
{
    [PostgreSqlFact]
    public async Task PostgreSqlEnforcesUniquenessAndSeedIsIdempotent()
    {
        var baseConnectionString = Environment.GetEnvironmentVariable(PostgreSqlFactAttribute.ConnectionVariable)!;
        var schemaName = $"catalog_test_{Guid.NewGuid():N}";

        await CreateSchemaAsync(baseConnectionString, schemaName);

        try
        {
            var schemaConnection = new NpgsqlConnectionStringBuilder(baseConnectionString)
            {
                SearchPath = schemaName,
                IncludeErrorDetail = false
            }.ConnectionString;
            var options = new DbContextOptionsBuilder<LanguagePlatformDbContext>()
                .UseNpgsql(schemaConnection)
                .Options;

            await using var dbContext = new LanguagePlatformDbContext(options);
            await dbContext.Database.MigrateAsync(CancellationToken.None);

            var seeder = new CatalogDataSeeder(dbContext);
            await seeder.SeedAsync(CancellationToken.None);
            await seeder.SeedAsync(CancellationToken.None);

            Assert.Equal(3, await dbContext.Languages.CountAsync(CancellationToken.None));
            Assert.Equal(3, await dbContext.LearningPaths.CountAsync(CancellationToken.None));
            Assert.Equal(5, await dbContext.LearningPrograms.CountAsync(CancellationToken.None));
            Assert.Equal(0, await dbContext.Courses.CountAsync(CancellationToken.None));

            dbContext.Languages.Add(Language.Create("tr", "Duplicate Turkish", "Türkçe", TextDirection.LeftToRight));
            await Assert.ThrowsAsync<DbUpdateException>(() =>
                dbContext.SaveChangesAsync(CancellationToken.None));
            dbContext.ChangeTracker.Clear();

            var turkishId = await dbContext.Languages
                .Where(language => language.Code == LanguageCode.Create("tr"))
                .Select(language => language.Id)
                .SingleAsync(CancellationToken.None);
            var arabicId = await dbContext.Languages
                .Where(language => language.Code == LanguageCode.Create("ar"))
                .Select(language => language.Id)
                .SingleAsync(CancellationToken.None);

            dbContext.LearningPaths.Add(LearningPath.Create(turkishId, arabicId));
            await Assert.ThrowsAsync<DbUpdateException>(() =>
                dbContext.SaveChangesAsync(CancellationToken.None));
        }
        finally
        {
            await DropSchemaAsync(baseConnectionString, schemaName);
        }
    }

    private static async Task CreateSchemaAsync(string connectionString, string schemaName)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync(CancellationToken.None);
        await using var command = connection.CreateCommand();
        command.CommandText = $"CREATE SCHEMA \"{schemaName}\"";
        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }

    private static async Task DropSchemaAsync(string connectionString, string schemaName)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync(CancellationToken.None);
        await using var command = connection.CreateCommand();
        command.CommandText = $"DROP SCHEMA IF EXISTS \"{schemaName}\" CASCADE";
        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }
}
