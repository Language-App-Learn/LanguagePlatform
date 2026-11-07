using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Common;
using UglyToad.PdfPig;
using UglyToad.PdfPig.DocumentLayoutAnalysis.TextExtractor;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class PdfTextExtractor : IPdfTextExtractor
{
    internal const int MaxBytes = 2 * 1024 * 1024;
    internal const int MaxPages = 30;

    public IReadOnlyList<ExtractedPdfPage> Extract(byte[] original, CancellationToken cancellationToken)
    {
        Guard.Against(original.Length is < 8 or > MaxBytes || !original.AsSpan().StartsWith("%PDF-"u8),
            "Provide a PDF no larger than 2 MiB.");
        try
        {
            using var document = PdfDocument.Open(original, ParsingOptions.LenientParsingOff);
            Guard.Against(document.IsEncrypted, "Use an unencrypted PDF.");
            Guard.Against(document.NumberOfPages is < 1 or > MaxPages, "The PDF must contain between 1 and 30 pages.");
            var result = new List<ExtractedPdfPage>(document.NumberOfPages);
            foreach (var page in document.GetPages())
            {
                cancellationToken.ThrowIfCancellationRequested();
                var text = ContentOrderTextExtractor.GetText(page).Replace("\0", "", StringComparison.Ordinal);
                Guard.Against(text.Length > 64000, "A PDF page exceeds the extracted text limit.");
                result.Add(new ExtractedPdfPage(page.Number, text));
            }
            return result;
        }
        catch (Exception error) when (error is not (DomainException or OperationCanceledException or OutOfMemoryException)
            && (error.GetType().Assembly == typeof(PdfDocument).Assembly ||
                error.GetType().Namespace?.StartsWith("UglyToad.PdfPig", StringComparison.Ordinal) == true ||
                error is InvalidOperationException or ArgumentException or IOException or FormatException))
        {
            throw new DomainException("This PDF could not be read. Use a valid, unencrypted PDF.");
        }
    }
}
