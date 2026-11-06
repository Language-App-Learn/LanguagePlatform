using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.MediaManagement;

public sealed class MediaAccessPolicy : PlatformEntity
{
    public required string Code { get; init; }
    public bool IsPublic { get; init; }
    public bool RequiresEnrollment { get; init; }
    public bool RequiresEntitlement { get; init; }
}

