using System.Text.Json;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Infrastructure.CourseContent;

namespace LanguagePlatform.Api.Endpoints;

internal static class PdfExtractionWorker
{
    internal static async Task<int> RunAsync()
    {
        var buffer = new byte[ReadingPdfService.MaximumUploadBytes + 1];
        try
        {
            await using var stdin = Console.OpenStandardInput();
            var length = await stdin.ReadAtLeastAsync(buffer, buffer.Length, false);
            if (length > ReadingPdfService.MaximumUploadBytes) return 2;
            var pages = PdfTextExtractor.Extract(buffer.AsSpan(0, length).ToArray(), CancellationToken.None);
            await using var stdout = Console.OpenStandardOutput();
            await JsonSerializer.SerializeAsync(stdout, pages);
            return 0;
        }
        catch (DomainException)
        {
            return 2;
        }
        catch (IOException)
        {
            return 1;
        }
    }
}
