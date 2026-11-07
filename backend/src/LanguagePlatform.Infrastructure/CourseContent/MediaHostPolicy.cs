using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class MediaHostPolicy(bool requireAllowlist, IReadOnlyCollection<string> allowedHosts)
{
    public string Validate(string url)
    {
        Guard.Against(!CanServe(url), "Media requires an approved HTTPS host and no embedded credentials.");
        return url;
    }

    public bool CanServe(string? url) =>
        url is { Length: > 0 and <= 2000 } && !url.Any(char.IsControl)
        && Uri.TryCreate(url, UriKind.Absolute, out var parsed)
        && parsed.Scheme == Uri.UriSchemeHttps && parsed.IsDefaultPort && parsed.UserInfo.Length == 0
        && parsed.HostNameType == UriHostNameType.Dns && parsed.IdnHost.Contains('.') && !parsed.IsLoopback
        && (!requireAllowlist && allowedHosts.Count == 0 || allowedHosts.Contains(parsed.IdnHost, StringComparer.OrdinalIgnoreCase));
}
