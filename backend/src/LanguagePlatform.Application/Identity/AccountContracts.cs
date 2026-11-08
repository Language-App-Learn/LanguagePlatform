namespace LanguagePlatform.Application.Identity;

public sealed record AccountRegistration(string Email, string Password);
public sealed record AccountLogin(string Email, string Password, string? AuthenticatorCode = null);
public sealed record AccountRefresh(string RefreshToken);
public sealed record AccountEmail(string Email);
public sealed record AccountConfirmation(Guid UserId, string Code);
public sealed record AccountPasswordReset(string Email, string Code, string NewPassword);
public sealed record CurrentAccountDto(Guid Id, string Email, string? DisplayName);
public sealed record UpdatePreferences(Guid UiLanguageId, Guid? LearningPathId, int DailyGoalMinutes, bool NotificationsEnabled);
public sealed record PreferencesDto(Guid UiLanguageId, Guid? LearningPathId, Guid? SourceLanguageId,
    Guid? TargetLanguageId, int DailyGoalMinutes, bool NotificationsEnabled);

public interface IAccountEmailDelivery
{
    Task SendConfirmationAsync(string email, Guid userId, string code, CancellationToken cancellationToken);
    Task SendPasswordResetAsync(string email, string code, CancellationToken cancellationToken);
}
