using System.Threading.Channels;
using LanguagePlatform.Application.Identity;
using MailKit;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;

namespace LanguagePlatform.Infrastructure.Identity;

public sealed partial class SmtpAccountEmailDelivery(IOptions<SmtpAccountEmailOptions> options,
    ILogger<SmtpAccountEmailDelivery> logger) : BackgroundService, IAccountEmailDelivery
{
    private readonly Channel<MailRequest> pending = Channel.CreateBounded<MailRequest>(100);

    public static void Configure(IServiceCollection services, IConfiguration configuration)
    {
        var section = configuration.GetSection("AccountEmail:Smtp");
        if (!section.GetValue<bool>("Enabled")) return;
        services.AddOptions<SmtpAccountEmailOptions>().Bind(section)
            .Validate(x => Uri.CheckHostName(x.Host) != UriHostNameType.Unknown
                && x.Port is >= 1 and <= 65535 && MailboxAddress.TryParse(x.From, out _)
                && !string.IsNullOrWhiteSpace(x.Username) && !string.IsNullOrWhiteSpace(x.Password)
                && x.Security is nameof(SecureSocketOptions.StartTls) or nameof(SecureSocketOptions.SslOnConnect),
                "SMTP requires an authenticated relay, sender, port and mandatory TLS.")
            .ValidateOnStart();
        services.AddSingleton<SmtpAccountEmailDelivery>();
        services.AddSingleton<IAccountEmailDelivery>(x => x.GetRequiredService<SmtpAccountEmailDelivery>());
        services.AddHostedService(x => x.GetRequiredService<SmtpAccountEmailDelivery>());
    }

    public Task SendConfirmationAsync(string email, Guid userId, string code, CancellationToken cancellationToken) =>
        Enqueue(new MailRequest(email, "LanguagePlatform e-posta doğrulaması",
            $"Uygulamadaki doğrulama ekranına aşağıdaki bilgileri girin.\n\nKullanıcı kimliği: {userId:D}\nKod: {code}\n\nBu işlemi siz başlatmadıysanız e-postayı yok sayın."),
            cancellationToken);

    public Task SendPasswordResetAsync(string email, string code, CancellationToken cancellationToken) =>
        Enqueue(new MailRequest(email, "LanguagePlatform parola sıfırlama",
            $"Uygulamadaki parola sıfırlama ekranına bu kodu girin.\n\nKod: {code}\n\nBu işlemi siz başlatmadıysanız e-postayı yok sayın."),
            cancellationToken);

    private Task Enqueue(MailRequest request, CancellationToken ct)
    {
        ct.ThrowIfCancellationRequested();
        if (!pending.Writer.TryWrite(request)) throw new AccountEmailDeliveryException();
        return Task.CompletedTask;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await foreach (var request in pending.Reader.ReadAllAsync(stoppingToken))
        {
            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(stoppingToken);
            timeout.CancelAfter(TimeSpan.FromSeconds(15));
            var ct = timeout.Token;
            try
            {
                var config = options.Value;
                using var smtp = new SmtpClient();
                await smtp.ConnectAsync(config.Host, config.Port, Enum.Parse<SecureSocketOptions>(config.Security), ct);
                await smtp.AuthenticateAsync(config.Username, config.Password, ct);
                using var message = new MimeMessage();
                message.From.Add(MailboxAddress.Parse(config.From));
                message.To.Add(new MailboxAddress(string.Empty, request.Email));
                message.Subject = request.Subject;
                message.Body = new TextPart("plain") { Text = request.Body };
                await smtp.SendAsync(message, ct);
                await smtp.DisconnectAsync(true, ct);
            }
            catch (Exception error) when (!stoppingToken.IsCancellationRequested &&
                error is IOException or System.Net.Sockets.SocketException or CommandException or ProtocolException
                    or MailKit.Security.AuthenticationException or SslHandshakeException or OperationCanceledException
                    or ArgumentException or NotSupportedException)
            {
                LogDeliveryFailed(logger);
            }
        }
    }

    [LoggerMessage(EventId = 410, Level = LogLevel.Warning, Message = "Account email relay delivery failed.")]
    private static partial void LogDeliveryFailed(ILogger logger);

    private sealed record MailRequest(string Email, string Subject, string Body);
}

public sealed class SmtpAccountEmailOptions
{
    public string Host { get; init; } = "";
    public int Port { get; init; } = 587;
    public string Security { get; init; } = "StartTls";
    public string Username { get; init; } = "";
    public string Password { get; init; } = "";
    public string From { get; init; } = "";
}
