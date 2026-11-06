using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Identity;
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlPersistenceTests
{
    [PostgreSqlFact]
    public Task MigrationChainAndCatalogConstraintsWork() => PostgreSqlTestSchema.RunAsync(async (_, db) =>
    {
        Assert.Equal(db.Database.GetMigrations(), await db.Database.GetAppliedMigrationsAsync());
        Assert.Empty(await db.Database.GetPendingMigrationsAsync());

        var seeder = new CatalogDataSeeder(db);
        await seeder.SeedAsync();
        await seeder.SeedAsync();
        Assert.Equal(3, await db.Languages.CountAsync());
        Assert.Equal(3, await db.LearningPaths.CountAsync());
        Assert.Equal(5, await db.LearningPrograms.CountAsync());
        Assert.Equal(0, await db.Courses.CountAsync());

        var path = await db.LearningPaths.FirstAsync();
        db.Languages.Add(Language.Create("TR", "Duplicate Turkish", "Türkçe", TextDirection.LeftToRight));
        await AssertFailureAsync(db, PostgresErrorCodes.UniqueViolation);
        db.LearningPaths.Add(LearningPath.Create(path.SourceLanguageId, path.TargetLanguageId));
        await AssertFailureAsync(db, PostgresErrorCodes.UniqueViolation);
        db.LearningPaths.Add(LearningPath.Create(Guid.NewGuid(), path.TargetLanguageId));
        await AssertFailureAsync(db, PostgresErrorCodes.ForeignKeyViolation);
        db.Languages.Remove(await db.Languages.SingleAsync(x => x.Id == path.SourceLanguageId));
        await AssertFailureAsync(db, PostgresErrorCodes.RestrictViolation);
        var same = path.SourceLanguageId;
        var id = Guid.NewGuid();
        var check = await Assert.ThrowsAsync<PostgresException>(() => db.Database.ExecuteSqlInterpolatedAsync(
            $"INSERT INTO learning_paths (id, source_language_id, target_language_id, is_active) VALUES ({id}, {same}, {same}, true)"));
        Assert.Equal(PostgresErrorCodes.CheckViolation, check.SqlState);
    });

    [PostgreSqlFact]
    public Task IdentityEmailUniquenessAndTransactionRollbackWork() => PostgreSqlTestSchema.RunAsync(async (_, db) =>
    {
        var user = NewUser("student");
        await using (var transaction = await db.Database.BeginTransactionAsync())
        {
            db.Users.Add(user);
            await db.SaveChangesAsync();
            await transaction.RollbackAsync();
        }
        db.ChangeTracker.Clear();
        Assert.False(await db.Users.AnyAsync());
        db.Users.Add(user);
        await db.SaveChangesAsync();
        Assert.Equal(DateTimeKind.Utc, (await db.Users.AsNoTracking().SingleAsync()).CreatedAtUtc.Kind);
        db.Users.Add(NewUser("other"));
        await AssertFailureAsync(db, PostgresErrorCodes.UniqueViolation);
    });

    [PostgreSqlFact]
    public Task PostgreSqlTypesAndXminEnforceTheSchemaContract() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await using var inspection = new NpgsqlConnection(connection);
        await inspection.OpenAsync();
        await using var columns = new NpgsqlCommand("""
            SELECT count(*) FROM information_schema.columns
            WHERE table_schema = current_schema() AND (
                (table_name = 'lesson_stages' AND column_name = 'settings_json' AND data_type = 'jsonb')
                OR (table_name = 'identity_users' AND column_name = 'created_at_utc' AND data_type = 'timestamp with time zone')
                OR (table_name = 'identity_users' AND column_name = 'id' AND data_type = 'uuid'))
            """, inspection);
        Assert.Equal(3L, await columns.ExecuteScalarAsync());

        await new CatalogDataSeeder(db).SeedAsync();
        var user = NewUser("concurrency");
        var preference = new UserPreference { UserId = user.Id };
        preference.Update(CatalogSeedIds.English, CatalogSeedIds.TurkishToArabic, 15, false);
        db.AddRange(user, preference);
        await db.SaveChangesAsync();
        await using var stale = new LanguagePlatformDbContext(
            new DbContextOptionsBuilder<LanguagePlatformDbContext>().UseNpgsql(connection).Options);
        var stalePreference = await stale.Set<UserPreference>().SingleAsync(x => x.Id == preference.Id);
        preference.Update(CatalogSeedIds.English, null, 25, false);
        await db.SaveChangesAsync();
        stalePreference.Update(CatalogSeedIds.Turkish, null, 30, true);
        await Assert.ThrowsAsync<DbUpdateConcurrencyException>(() => stale.SaveChangesAsync());
    });

    private static ApplicationUser NewUser(string name) => new()
    {
        Id = Guid.NewGuid(), UserName = name, NormalizedUserName = name.ToUpperInvariant(),
        Email = "student@example.test", NormalizedEmail = "STUDENT@EXAMPLE.TEST"
    };

    private static async Task AssertFailureAsync(LanguagePlatformDbContext db, string state)
    {
        var error = await Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.Equal(state, Assert.IsType<PostgresException>(error.InnerException).SqlState);
        db.ChangeTracker.Clear();
    }
}
