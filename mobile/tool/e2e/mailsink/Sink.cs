using System.Text.Json;
using LanguagePlatform.Application.Identity;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

[assembly: HostingStartup(typeof(E2eMailSink.SinkStartup))]

namespace E2eMailSink;

// TEST HARNESS ONLY (scratch, never part of the repository): captures the
// confirmation / reset messages the API would email, into a local file, so a
// synthetic test account can be confirmed without any SMTP server.
public sealed class SinkStartup : IHostingStartup
{
    public void Configure(IWebHostBuilder builder) =>
        builder.ConfigureServices(s => s.AddSingleton<IAccountEmailDelivery, FileOutbox>());
}

public sealed class FileOutbox : IAccountEmailDelivery
{
    private static readonly object Gate = new();

    private static void Append(object entry)
    {
        var path = Environment.GetEnvironmentVariable("E2E_OUTBOX");
        if (string.IsNullOrEmpty(path)) return;
        lock (Gate) File.AppendAllText(path, JsonSerializer.Serialize(entry) + "\n");
    }

    public Task SendConfirmationAsync(string email, Guid userId, string code, CancellationToken ct)
    {
        Append(new { kind = "confirm", email, userId, code });
        return Task.CompletedTask;
    }

    public Task SendPasswordResetAsync(string email, string code, CancellationToken ct)
    {
        Append(new { kind = "reset", email, code });
        return Task.CompletedTask;
    }
}
