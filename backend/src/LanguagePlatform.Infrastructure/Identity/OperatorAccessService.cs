using System.Text.Json;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.Platform;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace LanguagePlatform.Infrastructure.Identity;

public sealed class OperatorAccessService(LanguagePlatformDbContext db, UserManager<ApplicationUser> users,
    IUserStore<ApplicationUser> store, IOptions<IdentityOptions> identity, TimeProvider clock)
{
    public async Task SetPermissionAsync(Guid userId, string permission, bool grant, string operatorName, CancellationToken ct)
    {
        Guard.Against(!Permissions.All.Contains(permission, StringComparer.Ordinal), "Unknown permission.");
        var user = await FindAsync(userId, ct);
        if (grant && (!user.IsActive || !user.EmailConfirmed || !user.TwoFactorEnabled
            || string.IsNullOrWhiteSpace(await users.GetAuthenticatorKeyAsync(user))))
            throw new StateConflictException("Activate and confirm the account and enroll its authenticator before granting privileges.");
        var claims = await db.UserClaims.Where(x => x.UserId == userId && x.ClaimType == Permissions.ClaimType
            && x.ClaimValue == permission).ToListAsync(ct);
        if (grant && claims.Count == 0)
            db.UserClaims.Add(new IdentityUserClaim<Guid> { UserId = userId, ClaimType = Permissions.ClaimType, ClaimValue = permission });
        else if (!grant && claims.Count > 0)
            db.UserClaims.RemoveRange(claims);
        else
            return;

        await SaveAsync(user, grant ? "permission.granted" : "permission.revoked",
            JsonSerializer.Serialize(new { permission, operatorName }), ct);
    }

    public async Task EnrollAuthenticatorAsync(Guid userId, string key, string proof, string operatorName, CancellationToken ct)
    {
        Guard.Against(key.Length is < 32 or > 64 || key.Any(c => c is not (>= 'A' and <= 'Z' or >= '2' and <= '7'))
            || proof.Length != 6 || !proof.All(char.IsAsciiDigit), "Provide a valid Base32 authenticator key and current code.");
        var user = await FindAsync(userId, ct);
        if (!user.IsActive || !user.EmailConfirmed || user.TwoFactorEnabled)
            throw new StateConflictException("Authenticator enrollment requires an active, confirmed account without MFA.");
        await ((IUserAuthenticatorKeyStore<ApplicationUser>)store).SetAuthenticatorKeyAsync(user, key, ct);
        if (!await users.VerifyTwoFactorTokenAsync(user, identity.Value.Tokens.AuthenticatorTokenProvider, proof))
            throw new DomainException("Authenticator verification failed.");
        user.TwoFactorEnabled = true;
        await SaveAsync(user, "authenticator.enrolled", JsonSerializer.Serialize(new { operatorName }), ct);
    }

    private async Task<ApplicationUser> FindAsync(Guid userId, CancellationToken ct) =>
        await db.Users.SingleOrDefaultAsync(x => x.Id == userId, ct) ?? throw new ResourceNotFoundException();

    private async Task SaveAsync(ApplicationUser user, string action, string changes, CancellationToken ct)
    {
        user.SecurityStamp = Guid.NewGuid().ToString("N");
        user.ConcurrencyStamp = Guid.NewGuid().ToString("N");
        db.Add(new AuditLog
        {
            Action = action, EntityType = nameof(ApplicationUser), EntityId = user.Id,
            OccurredAtUtc = clock.GetUtcNow().UtcDateTime, CorrelationId = Guid.NewGuid().ToString("N"),
            RedactedChangesJson = changes
        });
        await db.SaveChangesAsync(ct);
    }
}
