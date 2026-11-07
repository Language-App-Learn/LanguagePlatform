namespace LanguagePlatform.Application.Common;

public sealed class ResourceNotFoundException : Exception
{
    public ResourceNotFoundException() : base("The requested resource was not found.") { }
}
