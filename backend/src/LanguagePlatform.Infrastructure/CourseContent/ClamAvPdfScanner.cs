using System.Buffers.Binary;
using System.Net;
using System.Net.Sockets;
using System.Text;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class ClamAvPdfScanner(IPAddress host, int port) : IPdfMalwareScanner
{
    public async Task<bool> IsCleanAsync(ReadOnlyMemory<byte> original, CancellationToken cancellationToken)
    {
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        timeout.CancelAfter(TimeSpan.FromSeconds(10));
        var ct = timeout.Token;
        try
        {
            using var client = new TcpClient(host.AddressFamily);
            await client.ConnectAsync(host, port, ct);
            await using var stream = client.GetStream();
            await stream.WriteAsync("zINSTREAM\0"u8.ToArray(), ct);
            var size = new byte[sizeof(int)];
            BinaryPrimitives.WriteInt32BigEndian(size, original.Length);
            await stream.WriteAsync(size, ct);
            await stream.WriteAsync(original, ct);
            Array.Clear(size);
            await stream.WriteAsync(size, ct);

            var response = new byte[1024];
            var length = 0;
            while (length < response.Length)
            {
                var read = await stream.ReadAsync(response.AsMemory(length), ct);
                if (read == 0) break;
                var end = response.AsSpan(length, read).IndexOf((byte)0);
                if (end >= 0)
                {
                    var status = Encoding.ASCII.GetString(response, 0, length + end);
                    if (string.Equals(status, "stream: OK", StringComparison.Ordinal)) return true;
                    if (status.StartsWith("stream: ", StringComparison.Ordinal) && status.EndsWith(" FOUND", StringComparison.Ordinal))
                        return false;
                    break;
                }
                length += read;
            }
        }
        catch (Exception error) when (!cancellationToken.IsCancellationRequested
            && error is IOException or SocketException or OperationCanceledException)
        {
            throw Unavailable();
        }
        throw Unavailable();
    }

    private static ServiceUnavailableException Unavailable() => new("PDF scanning is unavailable.");
}
