using System.Text.Encodings.Web;
using LanguagePlatform.Infrastructure.Identity;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace LanguagePlatform.Api.Authentication;

public sealed class SessionAuthenticationHandler(
    IOptionsMonitor<AuthenticationSchemeOptions> options,
    ILoggerFactory logger,
    UrlEncoder encoder,
    MobileAccountService accounts) : AuthenticationHandler<AuthenticationSchemeOptions>(options, logger, encoder)
{
    public const string SchemeName = "LanguagePlatformSession";

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var token = await Context.AuthenticateAsync(IdentityConstants.BearerScheme);
        if (!token.Succeeded) return token;
        return await accounts.ValidateAsync(token.Principal!, Context.RequestAborted)
            ? AuthenticateResult.Success(new AuthenticationTicket(token.Principal!, token.Properties, SchemeName))
            : AuthenticateResult.Fail("The session is no longer active.");
    }

    protected override Task HandleChallengeAsync(AuthenticationProperties properties)
    {
        Response.Headers.WWWAuthenticate = "Bearer";
        return base.HandleChallengeAsync(properties);
    }
}
