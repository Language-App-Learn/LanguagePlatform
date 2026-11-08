namespace LanguagePlatform.Application.Common;

public sealed class StateConflictException(string message) : Exception(message);
