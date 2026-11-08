using LanguagePlatform.Application.Common;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace LanguagePlatform.Api.Authentication;

internal static class OperatorCommand
{
    internal static async Task<int> RunAsync(WebApplication app, string[] args, CancellationToken ct)
    {
        if (args.Length < 3 || !Guid.TryParse(args[2], out var userId) ||
            !(args is [_, "grant" or "revoke", _, _] or [_, "enroll-authenticator", _]))
        {
            await Console.Error.WriteLineAsync("Use operator grant|revoke <user-id> <permission> or operator enroll-authenticator <user-id>.");
            return 2;
        }

        try
        {
            await using var scope = app.Services.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<LanguagePlatformDbContext>();
            var target = new NpgsqlConnectionStringBuilder(db.Database.GetConnectionString());
            if (!string.Equals(target.Host, app.Configuration["Operator:ExpectedHost"], StringComparison.Ordinal) ||
                !string.Equals(target.Database, app.Configuration["Operator:ExpectedDatabase"], StringComparison.Ordinal) ||
                string.IsNullOrWhiteSpace(target.Host) || string.IsNullOrWhiteSpace(target.Database))
                throw new DomainException("The connection does not match the explicitly configured operator target.");
            var actualDatabase = await db.Database.SqlQuery<string>($"""SELECT current_database() AS "Value" """).SingleAsync(ct);
            if (!string.Equals(actualDatabase, target.Database, StringComparison.Ordinal))
                throw new DomainException("The connected database does not match the operator target.");
            var operations = scope.ServiceProvider.GetRequiredService<OperatorAccessService>();
            if (args[1] == "enroll-authenticator")
                await operations.EnrollAuthenticatorAsync(userId,
                    Environment.GetEnvironmentVariable("LANGUAGEPLATFORM_OPERATOR_TOTP_KEY") ?? "",
                    Environment.GetEnvironmentVariable("LANGUAGEPLATFORM_OPERATOR_TOTP_CODE") ?? "",
                    Environment.UserName, ct);
            else
                await operations.SetPermissionAsync(userId, args[3], args[1] == "grant", Environment.UserName, ct);
            await Console.Out.WriteLineAsync("Operator request completed.");
            return 0;
        }
        catch (Exception error) when (error is DomainException or StateConflictException or ResourceNotFoundException
            or DbUpdateException or NpgsqlException or InvalidOperationException)
        {
            await Console.Error.WriteLineAsync("Operator request rejected. Check target, account, authenticator and permission.");
            return 1;
        }
    }
}
