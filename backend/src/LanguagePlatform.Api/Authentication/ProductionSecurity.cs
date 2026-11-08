using System.Net;
using System.Security.Cryptography.X509Certificates;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Npgsql;

namespace LanguagePlatform.Api.Authentication;

internal static class ProductionSecurity
{
    internal static void Configure(WebApplicationBuilder builder)
    {
        var config = builder.Configuration;
        if (!builder.Environment.IsProduction() && !config.GetSection("DataProtection").Exists()) return;
        var directory = config["DataProtection:KeyDirectory"];
        var certificatePath = config["DataProtection:CertificatePath"];
        if (directory is null || certificatePath is null || !Path.IsPathFullyQualified(directory)
            || !Path.IsPathFullyQualified(certificatePath) || !Directory.Exists(directory))
            throw new InvalidOperationException("Data Protection requires a private absolute key directory and a protection certificate.");
        var protection = builder.Services.AddDataProtection()
            .SetApplicationName(config["DataProtection:ApplicationName"] ?? "LanguagePlatform")
            .SetDefaultKeyLifetime(TimeSpan.FromDays(90))
            .PersistKeysToFileSystem(new DirectoryInfo(directory))
            .ProtectKeysWithCertificate(LoadCertificate(certificatePath, config["DataProtection:CertificatePassword"]));
        var priorPath = config["DataProtection:PreviousCertificatePath"];
        if (priorPath is not null)
            protection.UnprotectKeysWithAnyCertificate(LoadCertificate(priorPath, config["DataProtection:PreviousCertificatePassword"]));

        var proxies = config.GetSection("ReverseProxy:KnownProxies").Get<string[]>() ?? [];
        if (proxies.Length == 0) return;
        var addresses = proxies.Select(value => IPAddress.TryParse(value, out var address) &&
            !address.Equals(IPAddress.Any) && !address.Equals(IPAddress.IPv6Any)
                ? address : throw new InvalidOperationException("Configure explicit trusted reverse proxy IP addresses.")).ToArray();
        builder.Services.Configure<ForwardedHeadersOptions>(options =>
        {
            options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
            options.ForwardLimit = 1;
            options.KnownIPNetworks.Clear();
            options.KnownProxies.Clear();
            foreach (var address in addresses) options.KnownProxies.Add(address);
        });
    }

    internal static string DatabaseConnection(IConfiguration config, IHostEnvironment environment)
    {
        var connection = config.GetConnectionString("LanguagePlatform");
        if (string.IsNullOrWhiteSpace(connection) && environment.IsProduction())
            throw new InvalidOperationException("Set the production PostgreSQL connection.");
        var target = new NpgsqlConnectionStringBuilder(connection ??
            "Host=localhost;Port=5432;Database=language_platform_dev;Username=postgres");
        if (environment.IsProduction() &&
            (target.SslMode != SslMode.VerifyFull || string.IsNullOrWhiteSpace(target.Host) ||
            string.IsNullOrWhiteSpace(target.Database) || target.Database is "postgres" or "language_platform_dev" or "language_platform_test"
            || string.IsNullOrWhiteSpace(target.Username) || target.Username.Equals("postgres", StringComparison.OrdinalIgnoreCase)))
            throw new InvalidOperationException("Production requires a dedicated database, a restricted user and TLS VerifyFull.");
        target.IncludeErrorDetail = false;
        target.PersistSecurityInfo = false;
        return target.ConnectionString;
    }

    internal static void VerifyHost(WebApplication app)
    {
        if (!app.Environment.IsProduction()) return;
        var hosts = app.Configuration["AllowedHosts"]?.Split(';', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
        if (hosts is not { Length: > 0 } || hosts.Any(x => x.Contains('*')))
            throw new InvalidOperationException("Configure explicit AllowedHosts in Production.");
        _ = DatabaseConnection(app.Configuration, app.Environment);
    }

    private static X509Certificate2 LoadCertificate(string path, string? password)
    {
        var certificate = X509CertificateLoader.LoadPkcs12FromFile(path, password, X509KeyStorageFlags.EphemeralKeySet);
        if (certificate.HasPrivateKey) return certificate;
        certificate.Dispose();
        throw new InvalidOperationException("Data Protection requires a certificate with a private key.");
    }
}
