using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.Identity;
using LanguagePlatform.Domain.Platform;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace LanguagePlatform.Infrastructure.Identity;

public sealed partial class MobileAccountService(
    UserManager<ApplicationUser> users,
    SignInManager<ApplicationUser> signIn,
    IOptions<IdentityOptions> identity,
    LanguagePlatformDbContext db,
    TimeProvider clock,
    IEnumerable<IAccountEmailDelivery> deliveries, ILogger<MobileAccountService> logger)
{
    public const string SessionClaim = "lp_session";
    public const string AuthenticationMethodClaim = "lp_amr";
    private const string NonceClaim = "lp_session_nonce";
    private const string AuthenticatorReplayProvider = "LanguagePlatform.Authenticator";
    private const string AuthenticatorReplayName = "RecentUses";
    private static readonly EmailAddressAttribute EmailAddress = new();
    private readonly IAccountEmailDelivery? delivery = deliveries.SingleOrDefault();
    public bool HasEmailDelivery => delivery is not null;

    public async Task RegisterAsync(AccountRegistration request, CancellationToken cancellationToken)
    {
        ValidateEmail(request.Email);
        ValidatePassword(request.Password);
        var user = new ApplicationUser { Id = Guid.NewGuid(), Email = request.Email, UserName = request.Email };
        foreach (var validator in users.PasswordValidators)
            EnsureSuccess(await validator.ValidateAsync(users, user, request.Password));
        if (await users.FindByEmailAsync(request.Email) is not null) return;
        try
        {
            var result = await users.CreateAsync(user, request.Password);
            if (result.Errors.Any(x => x.Code is "DuplicateEmail" or "DuplicateUserName")) return;
            EnsureSuccess(result);
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        {
            db.Entry(user).State = EntityState.Detached;
            if (await users.FindByEmailAsync(request.Email) is null) throw;
            return;
        }
        var code = await users.GenerateEmailConfirmationTokenAsync(user);
        await TryDeliverAsync(() => delivery!.SendConfirmationAsync(request.Email, user.Id, code, cancellationToken));
    }

    public async Task ResendConfirmationAsync(AccountEmail request, CancellationToken cancellationToken)
    {
        ValidateEmail(request.Email);
        var user = await users.FindByEmailAsync(request.Email);
        if (user is not { IsActive: true, EmailConfirmed: false }) return;
        var code = await users.GenerateEmailConfirmationTokenAsync(user);
        await TryDeliverAsync(() => delivery!.SendConfirmationAsync(request.Email, user.Id, code, cancellationToken));
    }

    public async Task ConfirmAsync(AccountConfirmation request)
    {
        ValidateCode(request.Code);
        var user = await users.FindByIdAsync(request.UserId.ToString());
        Guard.Against(user is null || !user.IsActive, "Invalid or expired confirmation code.");
        Guard.Against(!(await users.ConfirmEmailAsync(user!, request.Code)).Succeeded, "Invalid or expired confirmation code.");
    }

    public async Task RequestResetAsync(AccountEmail request, CancellationToken cancellationToken)
    {
        ValidateEmail(request.Email);
        var user = await users.FindByEmailAsync(request.Email);
        if (user is not { IsActive: true, EmailConfirmed: true }) return;
        var code = await users.GeneratePasswordResetTokenAsync(user);
        await TryDeliverAsync(() => delivery!.SendPasswordResetAsync(request.Email, code, cancellationToken));
    }

    public async Task ResetAsync(AccountPasswordReset request)
    {
        ValidateEmail(request.Email);
        ValidateCode(request.Code);
        ValidatePassword(request.NewPassword);
        var user = await users.FindByEmailAsync(request.Email);
        const string failure = "Invalid or expired reset code or password does not meet policy.";
        Guard.Against(user is not { IsActive: true, EmailConfirmed: true }, failure);
        Guard.Against(!(await users.ResetPasswordAsync(user!, request.Code, request.NewPassword)).Succeeded, failure);
        // Identity changes the security stamp. Validation rejects all existing tickets.
    }

    public async Task<ClaimsPrincipal?> LoginAsync(AccountLogin request, CancellationToken cancellationToken)
    {
        ValidateEmail(request.Email);
        ValidatePassword(request.Password);
        var user = await users.FindByEmailAsync(request.Email);
        if (user is null || !await CheckCredentialsAsync(user, request.Password, request.AuthenticatorCode, cancellationToken))
            return null;

        var now = clock.GetUtcNow().UtcDateTime;
        var session = new UserSession
        {
            UserId = user.Id, FamilyId = Guid.NewGuid(), CreatedAtUtc = now, ExpiresAtUtc = now.AddDays(14)
        };
        db.Add(session);
        return await IssueAsync(user, session, user.TwoFactorEnabled, cancellationToken);
    }

    public async Task<bool> RequestDeletionAsync(Guid userId, AccountDeletionRequest request, CancellationToken ct)
    {
        ValidatePassword(request.Password);
        var user = await db.Users.SingleOrDefaultAsync(x => x.Id == userId, ct);
        if (user is null || !await CheckCredentialsAsync(user, request.Password, request.AuthenticatorCode, ct)) return false;
        user.IsActive = false;
        user.SecurityStamp = Guid.NewGuid().ToString("N");
        user.ConcurrencyStamp = Guid.NewGuid().ToString("N");
        db.Add(new AuditLog
        {
            ActorId = userId, EntityId = userId, EntityType = nameof(ApplicationUser), Action = "privacy.deletion.requested",
            OccurredAtUtc = clock.GetUtcNow().UtcDateTime, CorrelationId = Guid.NewGuid().ToString("N"), RedactedChangesJson = "{}"
        });
        await db.SaveChangesAsync(ct);
        return true;
    }

    private async Task<bool> CheckCredentialsAsync(ApplicationUser user, string password, string? authenticatorCode,
        CancellationToken ct)
    {
        if (!user.IsActive || !user.EmailConfirmed ||
            !(await signIn.CheckPasswordSignInAsync(user, password, lockoutOnFailure: true)).Succeeded) return false;
        if (!user.TwoFactorEnabled) return true;
        if (authenticatorCode is null) return false;
        if (authenticatorCode is not { Length: 6 } code || !code.All(char.IsAsciiDigit)
            || !await users.VerifyTwoFactorTokenAsync(user, identity.Value.Tokens.AuthenticatorTokenProvider, code))
        {
            await users.AccessFailedAsync(user);
            return false;
        }
        if (!await ConsumeAuthenticatorCodeAsync(user, code, ct)) return false;
        user.AccessFailedCount = 0;
        return true;
    }

    private async Task<bool> ConsumeAuthenticatorCodeAsync(ApplicationUser user, string code, CancellationToken ct)
    {
        var key = await users.GetAuthenticatorKeyAsync(user);
        if (string.IsNullOrEmpty(key)) return false;
        var digest = Convert.ToHexString(HMACSHA256.HashData(Encoding.UTF8.GetBytes(key), Encoding.UTF8.GetBytes(code)));
        var token = await db.UserTokens.FindAsync([user.Id, AuthenticatorReplayProvider, AuthenticatorReplayName], ct);
        var now = clock.GetUtcNow().ToUnixTimeSeconds();
        var recent = token?.Value is { } json
            ? JsonSerializer.Deserialize<Dictionary<string, long>>(json)! : new Dictionary<string, long>(StringComparer.Ordinal);
        var active = recent.Where(x => x.Value > now - 300).ToDictionary(StringComparer.Ordinal);
        if (!active.TryAdd(digest, now)) return false;
        if (token is null)
        {
            token = new IdentityUserToken<Guid> { UserId = user.Id, LoginProvider = AuthenticatorReplayProvider, Name = AuthenticatorReplayName };
            db.UserTokens.Add(token);
        }
        token.Value = JsonSerializer.Serialize(active);
        user.ConcurrencyStamp = Guid.NewGuid().ToString("N");
        return true;
    }

    public async Task<ClaimsPrincipal?> RenewAsync(ClaimsPrincipal principal, CancellationToken cancellationToken)
    {
        var session = await FindSessionAsync(principal, cancellationToken);
        if (session is null) return null;
        var user = await signIn.ValidateSecurityStampAsync(principal);
        return await CanUseSessionAsync(user, principal)
            ? await IssueAsync(user!, session, user!.TwoFactorEnabled, cancellationToken)
            : null;
    }

    public async Task<bool> ValidateAsync(ClaimsPrincipal principal, CancellationToken cancellationToken)
    {
        if (await FindSessionAsync(principal, cancellationToken) is null) return false;
        var user = await signIn.ValidateSecurityStampAsync(principal);
        if (!await CanUseSessionAsync(user, principal)) return false;
        var claimed = principal.FindAll(Permissions.ClaimType).Select(x => x.Value).Distinct(StringComparer.Ordinal).ToArray();
        if (claimed.Length == 0) return true;
        var active = await db.UserClaims.Where(x => x.UserId == user!.Id && x.ClaimType == Permissions.ClaimType)
            .Select(x => x.ClaimValue).ToListAsync(cancellationToken);
        return claimed.All(permission => active.Contains(permission, StringComparer.Ordinal));
    }

    public async Task RevokeAsync(ClaimsPrincipal principal, CancellationToken cancellationToken)
    {
        var session = await FindSessionAsync(principal, cancellationToken);
        if (session is null) return;
        session.Revoke(clock.GetUtcNow().UtcDateTime);
        await db.SaveChangesAsync(cancellationToken);
    }

    public Task<CurrentAccountDto?> GetAccountAsync(Guid userId, CancellationToken cancellationToken) =>
        (from user in db.Users.AsNoTracking()
         where user.Id == userId
         join profile in db.Set<UserProfile>() on user.Id equals profile.UserId into profiles
         from profile in profiles.DefaultIfEmpty()
         select new CurrentAccountDto(user.Id, user.Email!, profile.DisplayName)).SingleOrDefaultAsync(cancellationToken);

    private async Task<bool> CanUseSessionAsync(ApplicationUser? user, ClaimsPrincipal principal) =>
        user is { IsActive: true, EmailConfirmed: true }
        && (!user.TwoFactorEnabled || principal.HasClaim(AuthenticationMethodClaim, "mfa"))
        && !await users.IsLockedOutAsync(user);

    private async Task<ClaimsPrincipal> IssueAsync(ApplicationUser user, UserSession session, bool mfa, CancellationToken cancellationToken)
    {
        var nonce = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
        session.Rotate(Hash(nonce));
        var principal = await signIn.CreateUserPrincipalAsync(user);
        var claims = (ClaimsIdentity)principal.Identity!;
        claims.AddClaim(new Claim(SessionClaim, session.Id.ToString()));
        claims.AddClaim(new Claim(NonceClaim, nonce));
        if (mfa) claims.AddClaim(new Claim(AuthenticationMethodClaim, "mfa"));
        await db.SaveChangesAsync(cancellationToken);
        return principal;
    }

    private Task<UserSession?> FindSessionAsync(ClaimsPrincipal principal, CancellationToken cancellationToken)
    {
        var nonce = principal.FindFirstValue(NonceClaim);
        if (!Guid.TryParse(principal.FindFirstValue(SessionClaim), out var sessionId)
            || !Guid.TryParse(principal.FindFirstValue(identity.Value.ClaimsIdentity.UserIdClaimType), out var userId)
            || nonce is null)
            return Task.FromResult<UserSession?>(null);
        var hash = Hash(nonce);
        var now = clock.GetUtcNow().UtcDateTime;
        return db.Set<UserSession>().SingleOrDefaultAsync(x => x.Id == sessionId && x.UserId == userId
            && x.RevokedAtUtc == null && x.ExpiresAtUtc > now && x.TokenHash == hash, cancellationToken);
    }

    private static string Hash(string nonce) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(nonce)));

    private async Task TryDeliverAsync(Func<Task> send)
    {
        try { await send(); }
        catch (AccountEmailDeliveryException) { LogDeliveryDeferred(logger); }
    }

    [LoggerMessage(EventId = 411, Level = LogLevel.Warning, Message = "Account email could not be queued.")]
    private static partial void LogDeliveryDeferred(ILogger logger);

    private static void ValidateEmail(string email) =>
        Guard.Against(string.IsNullOrWhiteSpace(email) || email.Length > 254 || !EmailAddress.IsValid(email), "A valid email is required.");

    private static void ValidatePassword(string password) =>
        Guard.Against(string.IsNullOrEmpty(password) || password.Length > 256, "Password length is invalid.");

    private static void ValidateCode(string code) =>
        Guard.Against(string.IsNullOrEmpty(code) || code.Length > 4096, "Code is invalid.");

    private static void EnsureSuccess(IdentityResult result) =>
        Guard.Against(!result.Succeeded, "The account request could not be completed. Check the supplied values and password policy.");
}
