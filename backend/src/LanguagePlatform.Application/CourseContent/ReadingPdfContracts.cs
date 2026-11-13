namespace LanguagePlatform.Application.CourseContent;

public interface IPdfTextExtractor
{
    Task<IReadOnlyList<ExtractedPdfPage>> ExtractAsync(byte[] original, CancellationToken cancellationToken);
}

public interface IPdfMalwareScanner
{
    Task<bool> IsCleanAsync(ReadOnlyMemory<byte> original, CancellationToken cancellationToken);
}

public sealed record ExtractedPdfPage(int Page, string Text);
public sealed record ReadingPdfDraftDto(Guid Id, uint Revision, bool Approved, IReadOnlyList<ExtractedPdfPage> Pages)
{
    public IReadOnlyList<ReviewedPdfLineDto> Lines { get; init; } = [];
}
public sealed record ReviewedPdfLineDto(Guid Id, int Page, int Order, string Text, bool HasReferenceAudio);
public sealed record ReviewReadingPdf(uint ExpectedVersion, IReadOnlyList<ReadingPageReview> Pages);
public sealed record ReadingPageReview(int Page, IReadOnlyList<string> Lines);
public sealed record ApprovedReadingLineDto(Guid Id, int Page, int Order, string Text);
public sealed record ApprovedReadingDto(IReadOnlyList<ApprovedReadingLineDto> Lines, bool HasOriginalPdf);
