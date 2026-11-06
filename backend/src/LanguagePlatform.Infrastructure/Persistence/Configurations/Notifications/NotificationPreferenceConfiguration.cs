using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Notifications;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Notifications;

public sealed class NotificationPreferenceConfiguration : IEntityTypeConfiguration<NotificationPreference>
{
    public void Configure(EntityTypeBuilder<NotificationPreference> builder)
    {
        ModelConventions.Configure(builder, "notification_preferences");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.Category).HasMaxLength(64).IsRequired();
        builder.Property(x => x.PushEnabled).IsRequired();
        builder.Property(x => x.EmailEnabled).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.UserId, x.Category }).IsUnique();

    }
}

