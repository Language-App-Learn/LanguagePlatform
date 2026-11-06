using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlAccountApiTests
{
    [PostgreSqlFact]
    public Task ConfirmedIdentityCanRotateAndRevokeRealSessions() => PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        await new CatalogDataSeeder(db).SeedAsync();
        var delivery = new TestDelivery();
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection }))
                .ConfigureServices(services => services.AddSingleton<IAccountEmailDelivery>(delivery)));
        using var client = factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost") });
        var email = "learner@example.test";
        var password = "Integration-Test1!";

        using var registration = await client.PostAsJsonAsync("/api/v1/auth/register", new AccountRegistration(email, password));
        Assert.Equal(HttpStatusCode.Accepted, registration.StatusCode);
        using var unconfirmed = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
        Assert.Equal(HttpStatusCode.Unauthorized, unconfirmed.StatusCode);
        using var confirmation = await client.PostAsJsonAsync("/api/v1/auth/confirm-email", delivery.Confirmation!);
        Assert.Equal(HttpStatusCode.NoContent, confirmation.StatusCode);
        using var login = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
        login.EnsureSuccessStatusCode();
        var first = (await login.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", first.AccessToken);
        var account = await client.GetFromJsonAsync<CurrentAccountDto>("/api/v1/me");
        Assert.Equal(delivery.Confirmation!.UserId, account!.Id);
        using var invalidPreference = await client.PutAsJsonAsync("/api/v1/me/preferences",
            new UpdatePreferences(CatalogSeedIds.English, Guid.NewGuid(), 10, false));
        Assert.Equal(HttpStatusCode.BadRequest, invalidPreference.StatusCode);
        using var savePreference = await client.PutAsJsonAsync("/api/v1/me/preferences",
            new UpdatePreferences(CatalogSeedIds.English, CatalogSeedIds.TurkishToArabic, 10, false));
        savePreference.EnsureSuccessStatusCode();
        var preference = (await client.GetFromJsonAsync<PreferencesDto>("/api/v1/me/preferences"))!;
        Assert.Equal(CatalogSeedIds.English, preference.UiLanguageId);
        Assert.Equal(CatalogSeedIds.Turkish, preference.SourceLanguageId);
        Assert.Equal(CatalogSeedIds.Arabic, preference.TargetLanguageId);

        client.DefaultRequestHeaders.Authorization = null;
        using var renewal = await client.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(first.RefreshToken));
        renewal.EnsureSuccessStatusCode();
        var second = (await renewal.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        using var replay = await client.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(first.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, replay.StatusCode);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", first.AccessToken);
        using var stale = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.Unauthorized, stale.StatusCode);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", second.AccessToken);
        using var logout = await client.PostAsync("/api/v1/auth/logout", null);
        Assert.Equal(HttpStatusCode.NoContent, logout.StatusCode);
        using var revoked = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.Unauthorized, revoked.StatusCode);

        client.DefaultRequestHeaders.Authorization = null;
        using var reset = await client.PostAsJsonAsync("/api/v1/auth/password-reset/request", new AccountEmail(email));
        Assert.Equal(HttpStatusCode.Accepted, reset.StatusCode);
        using var changed = await client.PostAsJsonAsync("/api/v1/auth/password-reset/confirm",
            new AccountPasswordReset(email, delivery.ResetCode!, "New-Integration1!"));
        Assert.Equal(HttpStatusCode.NoContent, changed.StatusCode);
        using var oldPassword = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
        Assert.Equal(HttpStatusCode.Unauthorized, oldPassword.StatusCode);
    });

    private sealed class TestDelivery : IAccountEmailDelivery
    {
        public AccountConfirmation? Confirmation { get; private set; }
        public string? ResetCode { get; private set; }

        public Task SendConfirmationAsync(string email, Guid userId, string code, CancellationToken cancellationToken)
        {
            Confirmation = new AccountConfirmation(userId, code);
            return Task.CompletedTask;
        }

        public Task SendPasswordResetAsync(string email, string code, CancellationToken cancellationToken)
        {
            ResetCode = code;
            return Task.CompletedTask;
        }
    }
}
