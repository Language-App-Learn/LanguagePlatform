using System.Buffers.Binary;
using System.Net;
using System.Net.Sockets;
using System.Text;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Infrastructure.CourseContent;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class ClamAvPdfScannerTests
{
    [Theory]
    [InlineData("stream: OK", true)]
    [InlineData("stream: Synthetic FOUND", false)]
    [InlineData("INSTREAM size limit exceeded. ERROR", null)]
    public async Task OnlyExplicitCleanReplyPermitsUpload(string reply, bool? expected)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(10));
        var ct = timeout.Token;
        using var listener = new TcpListener(IPAddress.Loopback, 0);
        listener.Start();
        var port = ((IPEndPoint)listener.LocalEndpoint).Port;
        var scanner = new ClamAvPdfScanner(IPAddress.Loopback, port);
        var data = "%PDF-1.7 test data"u8.ToArray();
        var server = ReplyAsync();
        if (expected is { } clean)
            Assert.Equal(clean, await scanner.IsCleanAsync(data, ct));
        else
            await Assert.ThrowsAsync<ServiceUnavailableException>(() => scanner.IsCleanAsync(data, ct));
        await server;

        async Task ReplyAsync()
        {
            using var peer = await listener.AcceptTcpClientAsync(ct);
            await using var stream = peer.GetStream();
            var command = new byte[10];
            await stream.ReadExactlyAsync(command, ct);
            Assert.Equal("zINSTREAM\0"u8.ToArray(), command);
            var length = new byte[sizeof(int)];
            await stream.ReadExactlyAsync(length, ct);
            Assert.Equal(data.Length, BinaryPrimitives.ReadInt32BigEndian(length));
            var received = new byte[data.Length];
            await stream.ReadExactlyAsync(received, ct);
            Assert.Equal(data, received);
            await stream.ReadExactlyAsync(length, ct);
            Assert.Equal(0, BinaryPrimitives.ReadInt32BigEndian(length));
            await stream.WriteAsync(Encoding.ASCII.GetBytes(reply + '\0'), ct);
        }
    }
}
