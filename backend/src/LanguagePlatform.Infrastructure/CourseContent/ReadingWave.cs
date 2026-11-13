using System.Buffers.Binary;
using System.Security.Cryptography;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Infrastructure.CourseContent;

public static class ReadingWave
{
    public const string ContentType = "audio/wav";
    public const int MaximumBytes = 640044;
    private const int HeaderBytes = 44;
    private const int MinimumBytes = HeaderBytes + 8000;

    public static async Task<byte[]> ReadAsync(Stream stream, CancellationToken ct)
    {
        var buffer = new byte[MaximumBytes + 1];
        using var deadline = CancellationTokenSource.CreateLinkedTokenSource(ct);
        deadline.CancelAfter(TimeSpan.FromSeconds(10));
        try
        {
            var length = await stream.ReadAtLeastAsync(buffer, buffer.Length, false, deadline.Token);
            if (length > MaximumBytes) throw new UploadTooLargeException();
            var audio = buffer.AsSpan(0, length);
            Guard.Against(!IsValid(audio), "Provide 0.25 to 20 seconds of 16 kHz, mono, 16-bit PCM WAV.");
            return audio.ToArray();
        }
        catch (OperationCanceledException) when (!ct.IsCancellationRequested)
        {
            throw new DomainException("The WAV upload timed out.");
        }
        finally
        {
            CryptographicOperations.ZeroMemory(buffer);
        }
    }

    private static bool IsValid(ReadOnlySpan<byte> audio) =>
        audio.Length >= MinimumBytes && audio.Length % 2 == 0 &&
        audio.StartsWith("RIFF"u8) && BinaryPrimitives.ReadUInt32LittleEndian(audio[4..]) == audio.Length - 8 &&
        audio[8..16].SequenceEqual("WAVEfmt "u8) &&
        BinaryPrimitives.ReadUInt32LittleEndian(audio[16..]) == 16 &&
        BinaryPrimitives.ReadUInt16LittleEndian(audio[20..]) == 1 &&
        BinaryPrimitives.ReadUInt16LittleEndian(audio[22..]) == 1 &&
        BinaryPrimitives.ReadUInt32LittleEndian(audio[24..]) == 16000 &&
        BinaryPrimitives.ReadUInt32LittleEndian(audio[28..]) == 32000 &&
        BinaryPrimitives.ReadUInt16LittleEndian(audio[32..]) == 2 &&
        BinaryPrimitives.ReadUInt16LittleEndian(audio[34..]) == 16 &&
        audio[36..40].SequenceEqual("data"u8) &&
        BinaryPrimitives.ReadUInt32LittleEndian(audio[40..]) == audio.Length - HeaderBytes;
}
