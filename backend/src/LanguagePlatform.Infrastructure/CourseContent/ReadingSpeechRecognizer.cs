using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using LanguagePlatform.Application.CourseContent;
using Microsoft.Extensions.Options;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class ReadingSpeechRecognizer(HttpClient client, IOptions<ReadingSpeechOptions> options) : IReadingSpeechRecognizer
{
    public async Task<ReadingRecognition?> RecognizeAsync(byte[] audio, CancellationToken ct)
    {
        var settings = options.Value;
        if (settings.Endpoint is null) return null;

        using var request = new HttpRequestMessage(HttpMethod.Post, settings.Endpoint);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", settings.Token);
        request.Content = new ByteArrayContent(audio);
        request.Content.Headers.ContentType = new MediaTypeHeaderValue(ReadingWave.ContentType);
        try
        {
            using var response = await client.SendAsync(request, ct);
            if (response.StatusCode != HttpStatusCode.OK) return null;
            return await response.Content.ReadFromJsonAsync<ReadingRecognition>(ct);
        }
        catch (Exception error) when (error is HttpRequestException or JsonException ||
            error is OperationCanceledException && !ct.IsCancellationRequested)
        {
            return null;
        }
    }
}
