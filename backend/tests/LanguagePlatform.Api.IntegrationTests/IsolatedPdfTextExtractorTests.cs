using LanguagePlatform.Domain.Common;
using LanguagePlatform.Infrastructure.CourseContent;
using UglyToad.PdfPig.Content;
using UglyToad.PdfPig.Core;
using UglyToad.PdfPig.Fonts.Standard14Fonts;
using UglyToad.PdfPig.Writer;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class IsolatedPdfTextExtractorTests
{
    [Fact]
    public async Task WorkerExtractsTextAndRejectsInvalidPdf()
    {
        var host = Environment.GetEnvironmentVariable("DOTNET_HOST_PATH") ?? "dotnet";
        var worker = new IsolatedPdfTextExtractor(host, typeof(Program).Assembly.Location);
        var builder = new PdfDocumentBuilder();
        var page = builder.AddPage(PageSize.A4);
        var font = builder.AddStandard14Font(Standard14Font.Helvetica);
        page.AddText("Worker proof", 12, new PdfPoint(25, 700), font);

        var text = await worker.ExtractAsync(builder.Build(), CancellationToken.None);
        Assert.Contains("Worker proof", Assert.Single(text).Text, StringComparison.Ordinal);
        await Assert.ThrowsAsync<DomainException>(() =>
            worker.ExtractAsync("%PDF-1.7 malformed file"u8.ToArray(), CancellationToken.None));
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() =>
            worker.ExtractAsync([], new CancellationToken(canceled: true)));
    }
}
