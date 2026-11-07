using System.ComponentModel;
using System.Diagnostics;
using System.Text.Json;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class IsolatedPdfTextExtractor(string executable, string? managedEntryPoint) : IPdfTextExtractor
{
    public const string WorkerCommand = "pdf-extract-worker";
    private const int MaximumResultBytes = 12 * 1024 * 1024;

    public async Task<IReadOnlyList<ExtractedPdfPage>> ExtractAsync(byte[] original, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        timeout.CancelAfter(TimeSpan.FromSeconds(15));
        var ct = timeout.Token;
        var start = new ProcessStartInfo(executable)
        {
            UseShellExecute = false, CreateNoWindow = true, RedirectStandardInput = true,
            RedirectStandardOutput = true, RedirectStandardError = true
        };
        start.Environment.Clear();
        foreach (var name in new[] { "PATH", "DOTNET_ROOT", "SystemRoot", "WINDIR" })
            if (Environment.GetEnvironmentVariable(name) is { } value) start.Environment[name] = value;
        if (managedEntryPoint is not null) start.ArgumentList.Add(managedEntryPoint);
        start.ArgumentList.Add(WorkerCommand);

        using var process = new Process { StartInfo = start };
        try
        {
            if (!process.Start()) throw Unavailable();
        }
        catch (Win32Exception)
        {
            throw Unavailable();
        }

        using var errorCancellation = CancellationTokenSource.CreateLinkedTokenSource(ct);
        var drainError = process.StandardError.BaseStream.CopyToAsync(Stream.Null, errorCancellation.Token);
        try
        {
            await using (var stdin = process.StandardInput.BaseStream)
                await stdin.WriteAsync(original, ct);
            using var output = new MemoryStream();
            var buffer = new byte[8192];
            int count;
            while ((count = await process.StandardOutput.BaseStream.ReadAsync(buffer, ct)) != 0)
            {
                if (output.Length + count > MaximumResultBytes) throw Unavailable();
                output.Write(buffer, 0, count);
            }
            await process.WaitForExitAsync(ct);
            await drainError;
            if (process.ExitCode == 2) throw new DomainException("This PDF could not be read. Use a valid, unencrypted PDF.");
            if (process.ExitCode != 0) throw Unavailable();
            return JsonSerializer.Deserialize<ExtractedPdfPage[]>(output.GetBuffer().AsSpan(0, (int)output.Length))
                ?? throw Unavailable();
        }
        catch (Exception error) when (!cancellationToken.IsCancellationRequested
            && error is IOException or JsonException or OperationCanceledException)
        {
            throw Unavailable();
        }
        finally
        {
            if (!process.HasExited)
            {
                try { process.Kill(entireProcessTree: true); }
                catch (InvalidOperationException) { }
            }
            await errorCancellation.CancelAsync();
            try { await drainError; }
            catch (Exception error) when (error is IOException or OperationCanceledException) { }
        }
    }

    private static ServiceUnavailableException Unavailable() => new("PDF extraction is temporarily unavailable.");
}
