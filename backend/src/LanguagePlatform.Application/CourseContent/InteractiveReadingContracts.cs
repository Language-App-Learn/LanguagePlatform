namespace LanguagePlatform.Application.CourseContent;

public interface IReadingSpeechRecognizer
{
    Task<ReadingRecognition?> RecognizeAsync(byte[] audio, CancellationToken ct);
}

public sealed record ReadingRecognition(string? Text, double? MinAverageLogProbability,
    double? MaxNoSpeechProbability, bool HasSpeech);

public sealed record InteractiveReadingLineDto(Guid Id, int Page, int Order, string Text,
    bool HasReferenceAudio, bool Approved);

public sealed record InteractiveReadingProgressDto(Guid VersionId, int TotalLines, Guid? CurrentLineId,
    bool Completed, bool AutomaticProgressionEnabled, IReadOnlyList<InteractiveReadingLineDto> AvailableLines);

public sealed record ReadingLineEvaluationDto(Guid Id, Guid LineId, string Status, string? Reason);
