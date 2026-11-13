namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class ReadingSpeechOptions
{
    public Uri? Endpoint { get; init; }
    public string? Token { get; init; }
    public bool AutomaticProgressionEnabled { get; init; }
    public double? MinimumAverageLogProbability { get; init; }
    public double? MaximumNoSpeechProbability { get; init; }
    public int TimeoutSeconds { get; init; } = 30;

    public bool IsValid() =>
        TimeoutSeconds is >= 1 and <= 60 &&
        (Endpoint is null ? Token is null :
            Endpoint.IsAbsoluteUri && Endpoint.UserInfo.Length == 0 &&
            Endpoint.AbsolutePath == "/internal/transcribe" && Endpoint.Query.Length == 0 && Endpoint.Fragment.Length == 0 &&
            (Endpoint.Scheme == Uri.UriSchemeHttps ||
             (Endpoint.Scheme == Uri.UriSchemeHttp && Endpoint.IsLoopback)) &&
            Token is { Length: >= 32 and <= 256 } && Token.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_')) &&
        (!AutomaticProgressionEnabled ||
            (Endpoint is not null && MinimumAverageLogProbability is < 0 and >= -10 &&
             MaximumNoSpeechProbability is > 0 and < 1));
}
