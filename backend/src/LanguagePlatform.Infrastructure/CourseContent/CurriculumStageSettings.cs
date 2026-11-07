using System.Text.Json;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Infrastructure.CourseContent;

internal sealed record CurriculumStageSettings(string? EvaluationRubric, string? AudioUrl, TeacherVideoDto? TeacherVideo)
{
    internal static string Create(DraftStage? input)
    {
        Guard.Against(input?.EvaluationRubric is not null && input.Kind != "speaking", "Only speaking uses a teacher evaluation rubric.");
        Guard.Against(input?.EvaluationRubric?.Contains('\0') == true, "The evaluation rubric contains an unsupported character.");
        Guard.Against(input?.AudioUrl is not null && input.Kind != "listening", "Only listening uses an authored audio URL.");
        Guard.Against(input?.TeacherVideo is not null && input.Kind != "reading", "Teacher video belongs to reading.");
        return JsonSerializer.Serialize(new CurriculumStageSettings(
            input?.EvaluationRubric is { } rubric ? Guard.Text(rubric, 8000, nameof(input.EvaluationRubric)) : null,
            input?.AudioUrl is { } url ? HttpsUrl(url) : null,
            input?.TeacherVideo is { } video ? new TeacherVideoDto(HttpsUrl(video.Url),
                Guard.Text(video.Title, 200, nameof(video.Title))) : null));
    }

    internal static CurriculumStageSettings Read(string json) => JsonSerializer.Deserialize<CurriculumStageSettings>(json)!;

    private static string HttpsUrl(string url)
    {
        Guard.Against(url is null || url.Length > 2000 || url.Any(char.IsControl) || !Uri.TryCreate(url, UriKind.Absolute, out var parsed)
            || parsed.Scheme != Uri.UriSchemeHttps || string.IsNullOrEmpty(parsed.Host) || parsed.UserInfo.Length != 0,
            "Media requires an absolute HTTPS URL without embedded credentials.");
        return url!;
    }
}
