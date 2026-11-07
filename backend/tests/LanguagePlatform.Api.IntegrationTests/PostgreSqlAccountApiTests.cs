using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Buffers.Binary;
using System.Globalization;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Platform;
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class PostgreSqlAccountApiTests
{
    [PostgreSqlFact]
    public Task EncryptedKeyRingKeepsTicketsValidAcrossHosts() => PostgreSqlTestSchema.RunAsync(async (connection, _) =>
    {
        var directory = Directory.CreateTempSubdirectory("lp-keys-");
        try
        {
            var certificatePath = Path.Combine(directory.FullName, "test-protection.pfx");
            using var rsa = RSA.Create(2048);
            var request = new CertificateRequest("CN=LanguagePlatform Test Keys", rsa, HashAlgorithmName.SHA256,
                RSASignaturePadding.Pkcs1);
            using var certificate = request.CreateSelfSigned(DateTimeOffset.UtcNow.AddMinutes(-1), DateTimeOffset.UtcNow.AddDays(1));
            await File.WriteAllBytesAsync(certificatePath, certificate.Export(X509ContentType.Pkcs12));
            const string email = "persistent-session@example.test";
            const string password = "Integration-Test1!";
            AccessTokenResponse tokens;
            await using (var first = Factory())
            {
                await using (var scope = first.Services.CreateAsyncScope())
                {
                    var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
                    var created = await users.CreateAsync(new ApplicationUser
                    {
                        Id = Guid.NewGuid(), UserName = email, Email = email, EmailConfirmed = true
                    }, password);
                    Assert.True(created.Succeeded);
                }
                using var client = first.CreateClient();
                using var login = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
                login.EnsureSuccessStatusCode();
                tokens = (await login.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
            }
            var keyFile = Assert.Single(directory.GetFiles("key-*.xml"));
            Assert.Contains("encryptedSecret", await File.ReadAllTextAsync(keyFile.FullName), StringComparison.Ordinal);
            await using var second = Factory();
            using var restarted = second.CreateClient();
            restarted.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
            using var account = await restarted.GetAsync("/api/v1/me");
            Assert.Equal(HttpStatusCode.OK, account.StatusCode);
            using var renewed = await restarted.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(tokens.RefreshToken));
            Assert.Equal(HttpStatusCode.OK, renewed.StatusCode);

            WebApplicationFactory<Program> Factory() => new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.UseEnvironment("Testing").UseSetting("DataProtection:KeyDirectory", directory.FullName)
                    .UseSetting("DataProtection:CertificatePath", certificatePath)
                    .ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(
                        new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection })));
        }
        finally
        {
            directory.Delete(recursive: true);
        }
    });

    [PostgreSqlFact]
    public Task EmailFailureDoesNotRevealAccountsAndOperatorChangesRevokeSessions() =>
        PostgreSqlTestSchema.RunAsync(async (connection, db) =>
    {
        var delivery = new TestDelivery { Unavailable = true };
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.UseEnvironment("Testing").ConfigureAppConfiguration((_, config) =>
                config.AddInMemoryCollection(new Dictionary<string, string?> { ["ConnectionStrings:LanguagePlatform"] = connection }))
                .ConfigureServices(services => services.AddSingleton<IAccountEmailDelivery>(delivery)));
        using var client = factory.CreateClient();
        const string email = "mfa-operator@example.test";
        const string password = "Integration-Test1!";
        using var registration = await client.PostAsJsonAsync("/api/v1/auth/register", new AccountRegistration(email, password));
        Assert.Equal(HttpStatusCode.Accepted, registration.StatusCode);
        Assert.Null(delivery.Confirmation);
        using var failedResend = await client.PostAsJsonAsync("/api/v1/auth/confirm-email/resend", new AccountEmail(email));
        using var unknownResend = await client.PostAsJsonAsync("/api/v1/auth/confirm-email/resend", new AccountEmail("unknown@example.test"));
        Assert.Equal(HttpStatusCode.Accepted, failedResend.StatusCode);
        Assert.Equal(failedResend.StatusCode, unknownResend.StatusCode);
        Assert.Equal(await failedResend.Content.ReadAsStringAsync(), await unknownResend.Content.ReadAsStringAsync());
        delivery.Unavailable = false;
        using var resend = await client.PostAsJsonAsync("/api/v1/auth/confirm-email/resend", new AccountEmail(email));
        Assert.Equal(HttpStatusCode.Accepted, resend.StatusCode);
        using var confirmed = await client.PostAsJsonAsync("/api/v1/auth/confirm-email", delivery.Confirmation!);
        Assert.Equal(HttpStatusCode.NoContent, confirmed.StatusCode);
        var userId = delivery.Confirmation!.UserId;
        var first = await LoginAsync(new AccountLogin(email, password));
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", first.AccessToken);
        using var studentPublish = await client.PostAsJsonAsync($"/api/v1/admin/lesson-versions/{Guid.NewGuid()}/withdraw",
            new { reason = "permission check" });
        Assert.Equal(HttpStatusCode.Forbidden, studentPublish.StatusCode);

        // Synthetic RFC 6238 seed for this disposable account only.
        var secret = RandomNumberGenerator.GetBytes(20);
        var base32 = ToBase32(secret);
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var operations = scope.ServiceProvider.GetRequiredService<OperatorAccessService>();
            await Assert.ThrowsAsync<StateConflictException>(() =>
                operations.SetPermissionAsync(userId, Permissions.ContentPublish, true, "test-operator", CancellationToken.None));
            await operations.EnrollAuthenticatorAsync(userId, base32, Totp(secret), "test-operator", CancellationToken.None);
            await operations.SetPermissionAsync(userId, Permissions.ContentPublish, true, "test-operator", CancellationToken.None);
        }
        using var invalidated = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.Unauthorized, invalidated.StatusCode);
        client.DefaultRequestHeaders.Authorization = null;
        using var passwordOnly = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password));
        Assert.Equal(HttpStatusCode.Unauthorized, passwordOnly.StatusCode);
        var code = Totp(secret);
        var privileged = await LoginAsync(new AccountLogin(email, password, code));
        using var repeatedCode = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, password, code));
        Assert.Equal(HttpStatusCode.Unauthorized, repeatedCode.StatusCode);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", privileged.AccessToken);
        using var permitted = await client.PostAsJsonAsync($"/api/v1/admin/lesson-versions/{Guid.NewGuid()}/withdraw",
            new { reason = "permission check" });
        Assert.Equal(HttpStatusCode.NotFound, permitted.StatusCode);
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var operations = scope.ServiceProvider.GetRequiredService<OperatorAccessService>();
            await operations.SetPermissionAsync(userId, Permissions.ContentPublish, false, "test-operator", CancellationToken.None);
        }
        using var revoked = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.Unauthorized, revoked.StatusCode);
        using var refresh = await client.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(privileged.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, refresh.StatusCode);
        Assert.Equal(3, await db.Set<AuditLog>().CountAsync(x => x.EntityId == userId));

        async Task<AccessTokenResponse> LoginAsync(AccountLogin request)
        {
            using var login = await client.PostAsJsonAsync("/api/v1/auth/login", request);
            login.EnsureSuccessStatusCode();
            return (await login.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        }
    });

    private static string Totp(byte[] key)
    {
        Span<byte> step = stackalloc byte[8];
        BinaryPrimitives.WriteInt64BigEndian(step, DateTimeOffset.UtcNow.ToUnixTimeSeconds() / 30);
#pragma warning disable CA5350 // RFC 6238 / Identity authenticator interoperability.
        var hmac = HMACSHA1.HashData(key, step);
#pragma warning restore CA5350
        var offset = hmac[^1] & 15;
        var value = BinaryPrimitives.ReadInt32BigEndian(hmac.AsSpan(offset)) & int.MaxValue;
        return (value % 1_000_000).ToString("D6", CultureInfo.InvariantCulture);
    }

    private static string ToBase32(byte[] bytes)
    {
        const string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
        var result = new char[32];
        for (var i = 0; i < result.Length; i++)
        {
            var bit = i * 5;
            var index = bit / 8;
            var pair = bytes[index] << 8 | (index + 1 < bytes.Length ? bytes[index + 1] : 0);
            result[i] = alphabet[(pair >> (11 - bit % 8)) & 31];
        }
        return new string(result);
    }

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
        var racing = await Task.WhenAll(
            client.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(first.RefreshToken)),
            client.PostAsJsonAsync("/api/v1/auth/refresh", new AccountRefresh(first.RefreshToken)));
        AccessTokenResponse second;
        try
        {
            var winner = Assert.Single(racing, response => response.StatusCode == HttpStatusCode.OK);
            var loser = Assert.Single(racing, response => response != winner);
            Assert.Contains(loser.StatusCode, new[] { HttpStatusCode.Unauthorized, HttpStatusCode.Conflict });
            second = (await winner.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        }
        finally
        {
            foreach (var response in racing) response.Dispose();
        }
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

        using var newLogin = await client.PostAsJsonAsync("/api/v1/auth/login", new AccountLogin(email, "New-Integration1!"));
        newLogin.EnsureSuccessStatusCode();
        var afterReset = (await newLogin.Content.ReadFromJsonAsync<AccessTokenResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", afterReset.AccessToken);
        using var exportResponse = await client.GetAsync("/api/v1/me/privacy/export");
        exportResponse.EnsureSuccessStatusCode();
        var export = (await exportResponse.Content.ReadFromJsonAsync<AccountDataExport>())!;
        Assert.Equal(email, export.Account.Email);
        Assert.NotNull(export.Preferences);
        Assert.True(exportResponse.Headers.CacheControl!.NoStore);
        using var badDeletion = await client.PostAsJsonAsync("/api/v1/me/privacy/deletion-request", new AccountDeletionRequest(password));
        Assert.Equal(HttpStatusCode.Unauthorized, badDeletion.StatusCode);
        using var deletion = await client.PostAsJsonAsync("/api/v1/me/privacy/deletion-request",
            new AccountDeletionRequest("New-Integration1!"));
        Assert.Equal(HttpStatusCode.Accepted, deletion.StatusCode);
        using var afterDeletion = await client.GetAsync("/api/v1/me");
        Assert.Equal(HttpStatusCode.Unauthorized, afterDeletion.StatusCode);
        Assert.Equal(1, await db.Set<AuditLog>().CountAsync(x => x.EntityId == account.Id && x.Action == "privacy.deletion.requested"));
    });

    private sealed class TestDelivery : IAccountEmailDelivery
    {
        public bool Unavailable { get; set; }
        public AccountConfirmation? Confirmation { get; private set; }
        public string? ResetCode { get; private set; }

        public Task SendConfirmationAsync(string email, Guid userId, string code, CancellationToken cancellationToken)
        {
            if (Unavailable) throw new AccountEmailDeliveryException();
            Confirmation = new AccountConfirmation(userId, code);
            return Task.CompletedTask;
        }

        public Task SendPasswordResetAsync(string email, string code, CancellationToken cancellationToken)
        {
            if (Unavailable) throw new AccountEmailDeliveryException();
            ResetCode = code;
            return Task.CompletedTask;
        }
    }
}
