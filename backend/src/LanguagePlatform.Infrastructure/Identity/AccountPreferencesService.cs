using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.Identity;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Identity;

public sealed class AccountPreferencesService(LanguagePlatformDbContext db)
{
    public Task<PreferencesDto?> FindAsync(Guid userId, CancellationToken cancellationToken) =>
        (from preference in db.Set<UserPreference>().AsNoTracking()
         where preference.UserId == userId
         join path in db.LearningPaths on preference.LearningPathId equals (Guid?)path.Id into paths
         from path in paths.DefaultIfEmpty()
         select new PreferencesDto(preference.UiLanguageId, preference.LearningPathId,
             (Guid?)path.SourceLanguageId, (Guid?)path.TargetLanguageId,
             preference.DailyGoalMinutes, preference.NotificationsEnabled)).SingleOrDefaultAsync(cancellationToken);

    public async Task<PreferencesDto> UpdateAsync(Guid userId, UpdatePreferences request, CancellationToken cancellationToken)
    {
        Guard.Against(!await db.Languages.AnyAsync(x => x.Id == request.UiLanguageId && x.IsActive, cancellationToken),
            "The interface language is not active.");
        LearningPath? path = null;
        if (request.LearningPathId is { } id)
        {
            path = await db.LearningPaths.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id && x.IsActive
                && x.SourceLanguage.IsActive && x.TargetLanguage.IsActive, cancellationToken);
            Guard.Against(path is null, "The learning path is not active.");
        }
        var preference = await db.Set<UserPreference>().SingleOrDefaultAsync(x => x.UserId == userId, cancellationToken);
        if (preference is null)
        {
            preference = new UserPreference { UserId = userId };
            db.Add(preference);
        }
        preference.Update(request.UiLanguageId, request.LearningPathId, request.DailyGoalMinutes, request.NotificationsEnabled);
        await db.SaveChangesAsync(cancellationToken);
        return new PreferencesDto(preference.UiLanguageId, preference.LearningPathId, path?.SourceLanguageId,
            path?.TargetLanguageId, preference.DailyGoalMinutes, preference.NotificationsEnabled);
    }
}
