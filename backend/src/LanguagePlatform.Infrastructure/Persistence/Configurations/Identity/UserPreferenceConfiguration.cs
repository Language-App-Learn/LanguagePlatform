using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Identity;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Identity;

public sealed class UserPreferenceConfiguration : IEntityTypeConfiguration<UserPreference>
{
    public void Configure(EntityTypeBuilder<UserPreference> builder)
    {
        ModelConventions.Configure(builder, "user_preferences");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.UiLanguageId).IsRequired();
        builder.Property(x => x.DailyGoalMinutes).IsRequired();
        builder.Property(x => x.NotificationsEnabled).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.UiLanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.UserId).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_user_preferences_1", "daily_goal_minutes BETWEEN 1 AND 1440"));

    }
}

