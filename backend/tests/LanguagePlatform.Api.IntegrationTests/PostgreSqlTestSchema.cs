using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace LanguagePlatform.Api.IntegrationTests;

internal static class PostgreSqlTestSchema
{
    public static async Task RunAsync(Func<string, LanguagePlatformDbContext, Task> test)
    {
        var connection = new NpgsqlConnectionStringBuilder(
            Environment.GetEnvironmentVariable(PostgreSqlFactAttribute.ConnectionVariable))
        {
            IncludeErrorDetail = false,
            Pooling = false
        };
        if (connection.Database != "language_platform_test"
            || connection.Host is not ("localhost" or "127.0.0.1" or "::1"))
        {
            throw new InvalidOperationException("Integration tests require a dedicated loopback language_platform_test database.");
        }

        var schema = $"lp_test_{Guid.NewGuid():N}";
        await using var admin = new NpgsqlConnection(connection.ConnectionString);
        await admin.OpenAsync();
        await using var verify = new NpgsqlCommand("select current_database(), current_setting('server_version_num')::int", admin);
        await using (var reader = await verify.ExecuteReaderAsync())
        {
            if (!await reader.ReadAsync() || reader.GetString(0) != "language_platform_test"
                || reader.GetInt32(1) / 10000 != 18)
                throw new InvalidOperationException("Integration tests require PostgreSQL 18 and language_platform_test.");
        }

        // The identifier is generated here and consists only of a fixed prefix and hex digits.
        await using var create = new NpgsqlCommand($"CREATE SCHEMA \"{schema}\"", admin);
        await create.ExecuteNonQueryAsync();
        try
        {
            connection.SearchPath = schema;
            var options = new DbContextOptionsBuilder<LanguagePlatformDbContext>()
                .UseNpgsql(connection.ConnectionString).Options;
            await using var context = new LanguagePlatformDbContext(options);
            await context.Database.MigrateAsync();
            await test(connection.ConnectionString, context);
        }
        finally
        {
            await using var drop = new NpgsqlCommand($"DROP SCHEMA \"{schema}\" CASCADE", admin);
            await drop.ExecuteNonQueryAsync();
        }
    }
}
