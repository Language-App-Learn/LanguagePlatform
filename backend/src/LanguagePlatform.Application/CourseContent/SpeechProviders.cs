namespace LanguagePlatform.Application.CourseContent;

public interface IArabicTextToSpeech
{
    Task<SynthesizedSpeech> SynthesizeAsync(string arabicText, CancellationToken cancellationToken);
}

public sealed record SynthesizedSpeech(Stream Audio, string ContentType);

public interface IArabicSpeechTranscription
{
    Task<string> TranscribeAsync(Stream audio, string contentType, CancellationToken cancellationToken);
}

public interface IArabicSpeakingEvaluation
{
    Task<SpeakingEvaluation> EvaluateAsync(string prompt, string approvedRubric, string transcript,
        CancellationToken cancellationToken);
}

public sealed record SpeakingEvaluation(decimal Score, string Feedback, string ModelVersion);
