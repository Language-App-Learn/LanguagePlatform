using System.Security.Cryptography;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.Reading;
using LanguagePlatform.Domain.StudentProgress;
using LanguagePlatform.Infrastructure.Persistence;
using LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Npgsql;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class InteractiveReadingService(LanguagePlatformDbContext db, ReadingPdfService pdf,
    IReadingSpeechRecognizer recognizer, IOptions<ReadingSpeechOptions> options, TimeProvider clock)
{
    public async Task<InteractiveReadingProgressDto?> GetProgressAsync(Guid student, Guid course, Guid lesson,
        CancellationToken ct)
    {
        var version = await pdf.ReadableVersionAsync(student, course, lesson, ct);
        if (version is null) return null;
        var lines = await LinesAsync(student, version.Value, ct);
        var firstPending = lines.FindIndex(x => !x.Approved);
        return new(version.Value, lines.Count, firstPending < 0 ? null : lines[firstPending].Id,
            lines.Count > 0 && firstPending < 0, options.Value.AutomaticProgressionEnabled,
            firstPending < 0 ? lines : lines.Take(firstPending + 1).ToArray());
    }

    public async Task<byte[]?> GetAudioAsync(Guid student, Guid course, Guid lesson, Guid lineId, CancellationToken ct)
    {
        var progress = await GetProgressAsync(student, course, lesson, ct);
        if (progress?.AvailableLines.Any(x => x.Id == lineId && x.HasReferenceAudio) != true) return null;
        return await db.Set<ReadingTextSegment>().Where(x => x.Id == lineId)
            .Select(x => x.ReferenceAudio).SingleOrDefaultAsync(ct);
    }

    public async Task<ReadingLineEvaluationDto?> GetEvaluationAsync(Guid student, Guid course, Guid lesson,
        Guid evaluationId, CancellationToken ct)
    {
        var version = await pdf.ReadableVersionAsync(student, course, lesson, ct);
        if (version is null) return null;
        var matching = from row in Attempts
            join line in pdf.ReviewedLines(version.Value) on row.SegmentId equals line.Segment.Id
            where row.StudentId == student && row.Id == evaluationId
            select row;
        var attempt = await matching.SingleOrDefaultAsync(ct);
        if (attempt?.Status == ReadingLineStatus.Pending && attempt.DeadlineUtc <= clock.GetUtcNow().UtcDateTime)
        {
            await ExpireAsync(Attempts.Where(x => x.StudentId == student && x.Id == evaluationId), ct);
            attempt = await matching.SingleOrDefaultAsync(ct);
        }
        return attempt is null ? null : Present(attempt);
    }

    public async Task<ReadingLineEvaluationDto?> SubmitAsync(Guid student, Guid course, Guid lesson, Guid lineId,
        Guid key, Stream stream, CancellationToken ct)
    {
        Guard.Against(key == Guid.Empty, "Provide a nonempty Idempotency-Key UUID.");
        var version = await pdf.ReadableVersionAsync(student, course, lesson, ct);
        if (version is null) return null;
        var lines = await LinesAsync(student, version.Value, ct);
        var line = lines.Find(x => x.Id == lineId);
        if (line is null) return null;
        if (!await HasStartedAsync(student, course, version.Value, ct))
            throw new StateConflictException("Start the lesson before submitting its reading lines.");

        var audio = await ReadingWave.ReadAsync(stream, ct);
        try
        {
            var digest = SHA256.HashData(audio);
            var keyedAttempts = Attempts.Where(x => x.StudentId == student && x.IdempotencyKey == key);
            await ExpireAsync(keyedAttempts, ct);
            var existing = await keyedAttempts.SingleOrDefaultAsync(ct);
            if (existing is not null) return Replay(existing, lineId, digest);
            if (lines.Find(x => !x.Approved)?.Id != lineId)
                throw new StateConflictException("Submit only the current unfinished reading line.");

            await ExpireAsync(Attempts.Where(x => x.StudentId == student && x.SegmentId == lineId), ct);
            var now = clock.GetUtcNow().UtcDateTime;
            var claim = new ReadingLineAttempt
            {
                StudentId = student, SegmentId = lineId, IdempotencyKey = key, RecordingDigest = digest,
                CreatedAtUtc = now, DeadlineUtc = now.AddSeconds(options.Value.TimeoutSeconds + 15),
                Status = ReadingLineStatus.Pending
            };
            db.Add(claim);
            try
            {
                await db.SaveChangesAsync(ct);
            }
            catch (DbUpdateException error) when (error.InnerException is PostgresException
                {
                    SqlState: PostgresErrorCodes.UniqueViolation,
                    ConstraintName: ReadingLineAttemptConfiguration.ActiveLineIndex or ReadingLineAttemptConfiguration.IdempotencyIndex
                })
            {
                db.Entry(claim).State = EntityState.Detached;
                var winner = await keyedAttempts.SingleOrDefaultAsync(ct);
                if (winner is not null) return Replay(winner, lineId, digest);
                throw new StateConflictException("A reading evaluation is in progress or the line is already approved.");
            }

            var recognition = await recognizer.RecognizeAsync(audio, ct);
            var (status, reason) = Evaluate(line.Text, recognition);
            if (await pdf.ReadableVersionAsync(student, course, lesson, ct) != version ||
                !await HasStartedAsync(student, course, version.Value, ct))
                (status, reason) = (ReadingLineStatus.TechnicalError, "READING_UNAVAILABLE");
            var finishedAt = clock.GetUtcNow().UtcDateTime;
            var pending = Attempts.Where(x => x.Id == claim.Id && x.Status == ReadingLineStatus.Pending);
            await pending.Where(x => x.DeadlineUtc > finishedAt).ExecuteUpdateAsync(set => set
                .SetProperty(x => x.Status, status).SetProperty(x => x.Reason, reason), ct);
            await ExpireAsync(pending, ct);
            return Present(await Attempts.SingleAsync(x => x.Id == claim.Id, ct));
        }
        finally
        {
            CryptographicOperations.ZeroMemory(audio);
        }
    }

    public async Task<bool> IsAssessmentBlockedAsync(Guid student, Guid version, CancellationToken ct)
    {
        if (!options.Value.AutomaticProgressionEnabled) return false;
        var total = await pdf.ReviewedLines(version).CountAsync(ct);
        return total > 0 && total != await ApprovedLines(student, version).CountAsync(ct);
    }

    private IQueryable<ReadingLineAttempt> Attempts => db.Set<ReadingLineAttempt>().AsNoTracking();

    private IQueryable<Guid> ApprovedLines(Guid student, Guid version) =>
        from attempt in Attempts
        join line in pdf.ReviewedLines(version) on attempt.SegmentId equals line.Segment.Id
        where attempt.StudentId == student && attempt.Status == ReadingLineStatus.Approved
        select line.Segment.Id;

    private async Task<List<InteractiveReadingLineDto>> LinesAsync(Guid student, Guid version, CancellationToken ct)
    {
        var approved = (await ApprovedLines(student, version).ToListAsync(ct)).ToHashSet();
        return await pdf.ReviewedLines(version).Select(line => new InteractiveReadingLineDto(line.Segment.Id, line.Page,
            line.Segment.Sequence, line.Segment.Text, line.Segment.ReferenceAudio != null,
            approved.Contains(line.Segment.Id))).ToListAsync(ct);
    }

    private Task<bool> HasStartedAsync(Guid student, Guid course, Guid version, CancellationToken ct) =>
        (from progress in db.Set<LessonProgress>()
         join enrollment in db.Set<Enrollment>() on progress.EnrollmentId equals enrollment.Id
         where progress.LessonVersionId == version && enrollment.StudentId == student && enrollment.CourseId == course
            && enrollment.Status == "Active"
         select progress.Id).AnyAsync(ct);

    private Task<int> ExpireAsync(IQueryable<ReadingLineAttempt> attempts, CancellationToken ct)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        return attempts.Where(x => x.Status == ReadingLineStatus.Pending && x.DeadlineUtc <= now)
            .ExecuteUpdateAsync(set => set.SetProperty(x => x.Status, ReadingLineStatus.TechnicalError)
                .SetProperty(x => x.Reason, "EVALUATION_EXPIRED"), ct);
    }

    private (ReadingLineStatus Status, string? Reason) Evaluate(string expected, ReadingRecognition? recognition)
    {
        if (recognition is null) return (ReadingLineStatus.TechnicalError, "RECOGNIZER_UNAVAILABLE");
        if (!recognition.HasSpeech || string.IsNullOrWhiteSpace(recognition.Text))
            return (ReadingLineStatus.Inconclusive, "NO_SPEECH");
        if (!options.Value.AutomaticProgressionEnabled)
            return (ReadingLineStatus.Inconclusive, "PROGRESSION_DISABLED");
        if (!ArabicReadingText.ContainsArabic(recognition.Text) ||
            recognition.MinAverageLogProbability is not { } logProbability || !double.IsFinite(logProbability) ||
            logProbability > 0 || logProbability < options.Value.MinimumAverageLogProbability ||
            recognition.MaxNoSpeechProbability is not { } noSpeech || !double.IsFinite(noSpeech) ||
            noSpeech is < 0 or > 1 || noSpeech > options.Value.MaximumNoSpeechProbability)
            return (ReadingLineStatus.Inconclusive, "LOW_CONFIDENCE");
        return ArabicReadingText.Matches(expected, recognition.Text)
            ? (ReadingLineStatus.Approved, null)
            : (ReadingLineStatus.RetryRequired, "WORD_SEQUENCE_MISMATCH");
    }

    private static ReadingLineEvaluationDto Replay(ReadingLineAttempt attempt, Guid lineId, byte[] digest)
    {
        if (attempt.SegmentId != lineId || !CryptographicOperations.FixedTimeEquals(attempt.RecordingDigest, digest))
            throw new StateConflictException("This idempotency key is already in use for a different submission.");
        return Present(attempt);
    }

    private static ReadingLineEvaluationDto Present(ReadingLineAttempt attempt) => new(attempt.Id, attempt.SegmentId,
        attempt.Status switch
        {
            ReadingLineStatus.Pending => "PENDING",
            ReadingLineStatus.Approved => "APPROVED",
            ReadingLineStatus.RetryRequired => "RETRY_REQUIRED",
            ReadingLineStatus.Inconclusive => "INCONCLUSIVE",
            ReadingLineStatus.TechnicalError => "TECHNICAL_ERROR",
            _ => throw new InvalidOperationException("Invalid reading evaluation status.")
        }, attempt.Reason);
}
