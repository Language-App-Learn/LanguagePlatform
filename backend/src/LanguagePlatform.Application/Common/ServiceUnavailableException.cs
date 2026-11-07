namespace LanguagePlatform.Application.Common;

public sealed class ServiceUnavailableException(string message) : Exception(message);
