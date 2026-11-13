using System.Text.Json;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Reading;
using LanguagePlatform.Infrastructure.Persistence;
using LanguagePlatform.Infrastructure.StudentProgress;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class ReadingPdfService(LanguagePlatformDbContext db, IPdfTextExtractor extractor,
    StudentLearningService learning, TimeProvider clock, MediaHostPolicy mediaPolicy,
    IHostEnvironment environment, IEnumerable<IPdfMalwareScanner> scanners)
{
    public const int MaximumUploadBytes = PdfTextExtractor.MaxBytes;

    public async Task<ReadingPdfDraftDto> UploadAsync(Guid owner, Guid versionId, uint revision, string title, string rights,
        Stream stream, CancellationToken ct)
    {
        var scanner = scanners.SingleOrDefault();
        if (scanner is null && environment.IsProduction())
            throw new ServiceUnavailableException("PDF scanning is unavailable.");
        var version = await FindDraftAsync(versionId, revision, ct);
        if (await Sources(versionId).AnyAsync(ct))
            throw new StateConflictException("This version already has a PDF. Create a new draft to replace it.");
        title = Guard.Text(title, 200, nameof(title));
        rights = Guard.Text(rights, 2000, nameof(rights));
        Guard.Against(title.Contains('\0') || rights.Contains('\0'), "Invalid PDF metadata.");
        var buffer = new byte[MaximumUploadBytes + 1];
        var read = await stream.ReadAtLeastAsync(buffer, buffer.Length, false, ct);
        if (read > MaximumUploadBytes) throw new UploadTooLargeException();
        var original = buffer.AsSpan(0, read).ToArray();
        Guard.Against(original.Length < 8 || !original.AsSpan().StartsWith("%PDF-"u8), "Provide a valid PDF.");
        if (scanner is not null)
            Guard.Against(!await scanner.IsCleanAsync(original, ct), "This file did not pass the PDF safety check.");
        var pages = await extractor.ExtractAsync(original, ct);
        var arabic = LanguageCode.Create("ar");
        var language = await db.Languages.Where(x => x.Code == arabic && x.IsActive).Select(x => x.Id).SingleAsync(ct);
        var material = new ReadingMaterial
        {
            LessonVersionId = versionId, LanguageId = language, Title = title, CopyrightNotice = rights,
            UploadedBy = owner, RightsConfirmedAtUtc = clock.GetUtcNow().UtcDateTime,
            OriginalPdf = original, ExtractedPagesJson = JsonSerializer.Serialize(pages)
        };
        db.Add(material);
        version.RecordReadingMaterialChange();
        await db.SaveChangesAsync(ct);
        return new ReadingPdfDraftDto(material.Id, version.Version, false, pages);
    }

    public async Task<ReadingPdfDraftDto?> GetDraftAsync(Guid owner, Guid versionId, CancellationToken ct)
    {
        var row = await (from source in Sources(versionId).AsNoTracking()
            join version in db.Set<LessonVersion>() on source.LessonVersionId equals version.Id
            where source.UploadedBy == owner
            select new { source.Id, source.ExtractedPagesJson, source.ReviewedAtUtc, version.Version }).SingleOrDefaultAsync(ct);
        return row is null ? null : new ReadingPdfDraftDto(row.Id, row.Version, row.ReviewedAtUtc != null,
            DeserializePages(row.ExtractedPagesJson!))
        {
            Lines = await ReviewedLineMetadata(versionId).ToListAsync(ct)
        };
    }

    public async Task<ReadingPdfDraftDto> ReviewAsync(Guid owner, Guid versionId, ReviewReadingPdf request, CancellationToken ct)
    {
        var source = await Sources(versionId).SingleOrDefaultAsync(x => x.UploadedBy == owner, ct)
            ?? throw new ResourceNotFoundException();
        var version = await FindDraftAsync(versionId, request.ExpectedVersion, ct);
        if (source.ReviewedAtUtc is not null) throw new StateConflictException("This PDF has already been reviewed.");
        var extracted = DeserializePages(source.ExtractedPagesJson!);
        var pages = request.Pages;
        Guard.Against(pages is not { Count: >= 1 and <= PdfTextExtractor.MaxPages } || pages.Any(x => x is null)
            || pages.Select(x => x.Page).Distinct().Count() != pages.Count, "Provide distinct reviewed PDF pages.");
        var allowedPages = extracted.Select(x => x.Page).ToHashSet();
        foreach (var page in pages!.OrderBy(x => x.Page))
        {
            var lines = page.Lines;
            Guard.Against(!allowedPages.Contains(page.Page) || lines is not { Count: >= 1 and <= 150 }
                || lines.Any(line => string.IsNullOrWhiteSpace(line) || line.Length > 2000 ||
                    line.Contains('\0') || line.Contains('\r') || line.Contains('\n') || !ArabicReadingText.ContainsArabic(line)) ||
                lines.Sum(line => line.Length + 1) > 64000, "Provide valid single-line Arabic segments for an existing PDF page.");
            var passage = new ReadingPassage
            {
                ReadingMaterialId = source.Id, Sequence = page.Page, PageNumber = page.Page, OriginalText = string.Join('\n', lines!)
            };
            db.Add(passage);
            var offset = 0;
            for (var index = 0; index < lines!.Count; index++)
            {
                var line = lines[index];
                db.Add(new ReadingTextSegment
                {
                    ReadingPassageId = passage.Id, Sequence = index + 1, Text = line, StartOffset = offset,
                    Length = line.Length, AlignmentSchemaVersion = 1, AlignmentJson = "{}"
                });
                offset += line.Length + 1;
            }
        }
        source.Approve(clock.GetUtcNow().UtcDateTime);
        version.RecordReadingMaterialChange();
        await db.SaveChangesAsync(ct);
        return new ReadingPdfDraftDto(source.Id, version.Version, true, extracted)
        {
            Lines = await ReviewedLineMetadata(versionId).ToListAsync(ct)
        };
    }

    public async Task<ReadingPdfDraftDto> SetReferenceAudioAsync(Guid owner, Guid versionId, Guid lineId, uint revision,
        Stream stream, CancellationToken ct)
    {
        var source = await Sources(versionId).Where(x => x.UploadedBy == owner && x.ReviewedAtUtc != null)
            .Select(x => new { x.Id, x.ExtractedPagesJson }).SingleOrDefaultAsync(ct) ?? throw new ResourceNotFoundException();
        var version = await FindDraftAsync(versionId, revision, ct);
        var line = await (from passage in db.Set<ReadingPassage>()
            join segment in db.Set<ReadingTextSegment>() on passage.Id equals segment.ReadingPassageId
            where passage.ReadingMaterialId == source.Id && passage.PageNumber != null && segment.Id == lineId
            select segment).SingleOrDefaultAsync(ct) ?? throw new ResourceNotFoundException();
        line.SetReferenceAudio(await ReadingWave.ReadAsync(stream, ct));
        version.RecordReadingMaterialChange();
        await db.SaveChangesAsync(ct);
        return new ReadingPdfDraftDto(source.Id, version.Version, true, DeserializePages(source.ExtractedPagesJson!))
        {
            Lines = await ReviewedLineMetadata(versionId).ToListAsync(ct)
        };
    }

    public Task<byte[]?> GetOwnerPdfAsync(Guid owner, Guid versionId, CancellationToken ct) =>
        Sources(versionId).Where(x => x.UploadedBy == owner).Select(x => x.OriginalPdf).SingleOrDefaultAsync(ct);

    public async Task<ApprovedReadingDto?> GetPublishedAsync(Guid user, Guid courseId, Guid lessonId, CancellationToken ct)
    {
        var versionId = await ReadableVersionAsync(user, courseId, lessonId, ct);
        if (versionId is null) return null;
        var lines = await ReviewedLines(versionId.Value)
            .Select(x => new ApprovedReadingLineDto(x.Segment.Id, x.Page, x.Segment.Sequence, x.Segment.Text)).ToListAsync(ct);
        return new ApprovedReadingDto(lines, lines.Count > 0);
    }

    public async Task<byte[]?> GetPublishedPdfAsync(Guid user, Guid courseId, Guid lessonId, CancellationToken ct)
    {
        var versionId = await ReadableVersionAsync(user, courseId, lessonId, ct);
        return versionId is null ? null : await Sources(versionId.Value).Where(x => x.ReviewedAtUtc != null)
            .Select(x => x.OriginalPdf).SingleOrDefaultAsync(ct);
    }

    public async Task<CurriculumStageMediaDto?> GetStageMediaAsync(Guid user, Guid courseId, Guid lessonId, Guid stageId,
        CancellationToken ct)
    {
        var progress = await learning.GetCurriculumProgressAsync(user, courseId, lessonId, ct);
        if (progress?.Stages.Any(x => x.Id == stageId && x.Status is "available" or "completed") != true) return null;
        var json = await db.Set<LessonStage>().Where(x => x.Id == stageId && x.LessonVersionId == progress.VersionId)
            .Select(x => x.SettingsJson).SingleAsync(ct);
        var settings = CurriculumStageSettings.Read(json);
        var audio = mediaPolicy.CanServe(settings.AudioUrl) ? settings.AudioUrl : null;
        var video = mediaPolicy.CanServe(settings.TeacherVideo?.Url) ? settings.TeacherVideo : null;
        var blocked = (settings.AudioUrl is not null && audio is null) || (settings.TeacherVideo is not null && video is null);
        return new CurriculumStageMediaDto(audio, video,
            blocked ? "unconfigured" : audio is not null || video is not null ? "available" : "unavailable");
    }

    private IQueryable<ReadingMaterial> Sources(Guid versionId) =>
        db.Set<ReadingMaterial>().Where(x => x.LessonVersionId == versionId && x.OriginalPdf != null);

    private IQueryable<ReviewedPdfLineDto> ReviewedLineMetadata(Guid versionId) =>
        ReviewedLines(versionId).Select(x => new ReviewedPdfLineDto(x.Segment.Id, x.Page,
            x.Segment.Sequence, x.Segment.Text, x.Segment.ReferenceAudio != null));

    internal IQueryable<ReviewedPdfLine> ReviewedLines(Guid versionId) =>
        from source in Sources(versionId).AsNoTracking()
        join passage in db.Set<ReadingPassage>() on source.Id equals passage.ReadingMaterialId
        join segment in db.Set<ReadingTextSegment>() on passage.Id equals segment.ReadingPassageId
        where source.ReviewedAtUtc != null && passage.PageNumber != null
        orderby passage.Sequence, segment.Sequence
        select new ReviewedPdfLine { Segment = segment, Page = passage.PageNumber!.Value };

    internal sealed class ReviewedPdfLine
    {
        public required ReadingTextSegment Segment { get; init; }
        public required int Page { get; init; }
    }

    internal async Task<Guid?> ReadableVersionAsync(Guid user, Guid courseId, Guid lessonId, CancellationToken ct)
    {
        var progress = await learning.GetCurriculumProgressAsync(user, courseId, lessonId, ct);
        return progress?.Stages.Any(x => x.Kind == "reading" && x.Status is "available" or "completed") == true
            ? progress.VersionId : null;
    }

    private async Task<LessonVersion> FindDraftAsync(Guid versionId, uint revision, CancellationToken ct)
    {
        var version = await db.Set<LessonVersion>().SingleOrDefaultAsync(x => x.Id == versionId && x.UsesFiveStageCurriculum, ct)
            ?? throw new ResourceNotFoundException();
        if (version.Version != revision || version.Status != PublicationState.Draft)
            throw new StateConflictException("This version is no longer the editable draft revision.");
        return version;
    }

    private static ExtractedPdfPage[] DeserializePages(string json) => JsonSerializer.Deserialize<ExtractedPdfPage[]>(json)!;
}
