namespace LanguagePlatform.Application.Common;

public sealed class PermissionDeniedException : Exception
{
    public PermissionDeniedException() : base("Permission denied.") { }
}
