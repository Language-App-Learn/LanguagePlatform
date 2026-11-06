using System.Threading.RateLimiting;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;

namespace LanguagePlatform.Api.Authentication;

public static class MobileAuthentication
{
    public const string AccountRatePolicy = "account";

    public static void AddMobileAuthentication(this IServiceCollection services)
    {
        services.AddIdentityCore<ApplicationUser>(options =>
        {
            options.User.RequireUniqueEmail = true;
            options.SignIn.RequireConfirmedEmail = true;
            options.Password.RequiredLength = 12;
            options.Lockout.AllowedForNewUsers = true;
            options.Lockout.MaxFailedAccessAttempts = 5;
        }).AddRoles<IdentityRole<Guid>>().AddEntityFrameworkStores<LanguagePlatformDbContext>()
            .AddSignInManager().AddDefaultTokenProviders();

        services.AddAuthentication(SessionAuthenticationHandler.SchemeName)
            .AddBearerToken(IdentityConstants.BearerScheme, options =>
            {
                options.BearerTokenExpiration = TimeSpan.FromMinutes(10);
                options.RefreshTokenExpiration = TimeSpan.FromDays(14);
            })
            .AddScheme<AuthenticationSchemeOptions, SessionAuthenticationHandler>(
                SessionAuthenticationHandler.SchemeName, _ => { });
        services.AddAuthorizationBuilder();
        foreach (var permission in Permissions.All)
        {
            services.AddAuthorizationBuilder().AddPolicy(permission, policy =>
                policy.RequireAuthenticatedUser().RequireClaim(HttpCurrentActor.PermissionClaim, permission));
        }
        services.AddHttpContextAccessor();
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<MobileAccountService>();
        services.AddScoped<AccountPreferencesService>();
        services.AddScoped<ICurrentActor, HttpCurrentActor>();
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.AddPolicy(AccountRatePolicy, context => RateLimitPartition.GetFixedWindowLimiter(
                context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = 20, Window = TimeSpan.FromMinutes(1), QueueLimit = 0
                }));
        });
    }
}
