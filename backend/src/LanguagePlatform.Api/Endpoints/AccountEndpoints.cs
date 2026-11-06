using LanguagePlatform.Api.Authentication;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Infrastructure.Identity;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace LanguagePlatform.Api.Endpoints;

public static class AccountEndpoints
{
    public static void MapAccountEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var auth = endpoints.MapGroup("/api/v1/auth").WithTags("Account");
        var limited = auth.MapGroup("").RequireRateLimiting(MobileAuthentication.AccountRatePolicy);
        limited.MapPost("/register", async (AccountRegistration request, MobileAccountService accounts, CancellationToken ct) =>
        {
            if (!accounts.HasEmailDelivery) return DeliveryUnavailable();
            await accounts.RegisterAsync(request, ct);
            return Results.Accepted();
        }).Produces(202).ProducesProblem(400).ProducesProblem(503).ProducesProblem(429);

        limited.MapPost("/confirm-email", async (AccountConfirmation request, MobileAccountService accounts) =>
        {
            await accounts.ConfirmAsync(request);
            return TypedResults.NoContent();
        }).ProducesProblem(400).ProducesProblem(429);

        limited.MapPost("/confirm-email/resend", async (AccountEmail request, MobileAccountService accounts, CancellationToken ct) =>
        {
            if (!accounts.HasEmailDelivery) return DeliveryUnavailable();
            await accounts.ResendConfirmationAsync(request, ct);
            return Results.Accepted();
        }).Produces(202).ProducesProblem(400).ProducesProblem(503).ProducesProblem(429);

        limited.MapPost("/login", async (AccountLogin request, MobileAccountService accounts, HttpContext context, CancellationToken ct) =>
        {
            var principal = await accounts.LoginAsync(request, ct);
            context.Response.Headers.CacheControl = "no-store";
            return principal is null ? Results.Unauthorized() : Results.SignIn(principal, authenticationScheme: IdentityConstants.BearerScheme);
        }).Produces<AccessTokenResponse>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(429);

        limited.MapPost("/refresh", async (AccountRefresh request, MobileAccountService accounts,
            IOptionsMonitor<BearerTokenOptions> options, TimeProvider clock, HttpContext context, CancellationToken ct) =>
        {
            Guard.Against(string.IsNullOrWhiteSpace(request.RefreshToken) || request.RefreshToken.Length > 16384, "Refresh token is invalid.");
            var ticket = options.Get(IdentityConstants.BearerScheme).RefreshTokenProtector.Unprotect(request.RefreshToken);
            if (ticket?.Properties.ExpiresUtc is not { } expiry || expiry <= clock.GetUtcNow()) return Results.Unauthorized();
            var principal = await accounts.RenewAsync(ticket.Principal, ct);
            context.Response.Headers.CacheControl = "no-store";
            return principal is null ? Results.Unauthorized() : Results.SignIn(principal, authenticationScheme: IdentityConstants.BearerScheme);
        }).Produces<AccessTokenResponse>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(409).ProducesProblem(429);

        limited.MapPost("/password-reset/request", async (AccountEmail request, MobileAccountService accounts, CancellationToken ct) =>
        {
            if (!accounts.HasEmailDelivery) return DeliveryUnavailable();
            await accounts.RequestResetAsync(request, ct);
            return Results.Accepted();
        }).Produces(202).ProducesProblem(400).ProducesProblem(503).ProducesProblem(429);

        limited.MapPost("/password-reset/confirm", async (AccountPasswordReset request, MobileAccountService accounts) =>
        {
            await accounts.ResetAsync(request);
            return TypedResults.NoContent();
        }).ProducesProblem(400).ProducesProblem(429);

        auth.MapPost("/logout", async (HttpContext context, MobileAccountService accounts, CancellationToken ct) =>
        {
            await accounts.RevokeAsync(context.User, ct);
            return TypedResults.NoContent();
        }).RequireAuthorization().ProducesProblem(401).ProducesProblem(409);

        endpoints.MapGet("/api/v1/me", async (ICurrentActor actor, MobileAccountService accounts, CancellationToken ct) =>
        {
            if (actor.UserId is not { } userId) return Results.Unauthorized();
            var account = await accounts.GetAccountAsync(userId, ct);
            return account is null ? Results.Unauthorized() : Results.Ok(account);
        }).WithTags("Account").RequireAuthorization().Produces<CurrentAccountDto>().ProducesProblem(401);

        var preferences = endpoints.MapGroup("/api/v1/me/preferences").WithTags("Account").RequireAuthorization();
        preferences.MapGet("", async (ICurrentActor actor, AccountPreferencesService service, CancellationToken ct) =>
        {
            if (actor.UserId is not { } userId) return Results.Unauthorized();
            var saved = await service.FindAsync(userId, ct);
            return saved is null ? Results.Problem(statusCode: 404) : Results.Ok(saved);
        }).Produces<PreferencesDto>().ProducesProblem(401).ProducesProblem(404);
        preferences.MapPut("", async (UpdatePreferences request, ICurrentActor actor,
            AccountPreferencesService service, CancellationToken ct) =>
            actor.UserId is { } userId ? Results.Ok(await service.UpdateAsync(userId, request, ct)) : Results.Unauthorized())
            .Produces<PreferencesDto>().ProducesProblem(400).ProducesProblem(401).ProducesProblem(409);
    }

    private static IResult DeliveryUnavailable() =>
        Results.Problem(statusCode: StatusCodes.Status503ServiceUnavailable, title: "Account email delivery is unavailable.");
}
