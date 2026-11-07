using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Reading;

public sealed class ReadingMaterial : PlatformEntity
{
    public required Guid LessonVersionId { get; init; }
    public required Guid LanguageId { get; init; }
    public Guid? PdfAssetId { get; init; }
    public required string Title { get; init; }
    public required string CopyrightNotice { get; init; }
    public required Guid UploadedBy { get; init; }
    public required DateTime RightsConfirmedAtUtc { get; init; }
    public byte[]? OriginalPdf { get; init; }
    public string? ExtractedPagesJson { get; init; }
    public DateTime? ReviewedAtUtc { get; private set; }

    public void Approve(DateTime nowUtc)
    {
        Guard.Against(ReviewedAtUtc is not null, "This PDF has already been reviewed.");
        ReviewedAtUtc = nowUtc;
    }
}
