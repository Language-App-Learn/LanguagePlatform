using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace LanguagePlatform.Api.Health;

public sealed class PostgreSqlReadiness(IServiceScopeFactory scopes) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        await using var scope = scopes.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<LanguagePlatformDbContext>();
        if (!await db.Database.CanConnectAsync(cancellationToken))
            return HealthCheckResult.Unhealthy("PostgreSQL is unavailable.");
        return (await db.Database.GetPendingMigrationsAsync(cancellationToken)).Any()
            ? HealthCheckResult.Unhealthy("PostgreSQL schema is behind the application.")
            : HealthCheckResult.Healthy();
    }
}
