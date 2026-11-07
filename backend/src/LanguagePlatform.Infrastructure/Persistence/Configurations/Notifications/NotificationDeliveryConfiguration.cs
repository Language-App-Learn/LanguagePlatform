using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Notifications;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Notifications;

public sealed class NotificationDeliveryConfiguration : IEntityTypeConfiguration<NotificationDelivery>
{
    public void Configure(EntityTypeBuilder<NotificationDelivery> builder)
    {
        ModelConventions.Configure(builder, "notification_deliveries");
        builder.Property(x => x.NotificationId).IsRequired();
        builder.Property(x => x.DeviceRegistrationId).IsRequired();
        builder.Property(x => x.ProviderMessageId).HasMaxLength(128);
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.AttemptCount).IsRequired();
        builder.Property(x => x.DeliveredAtUtc);
        builder.HasOne<LanguagePlatform.Domain.Notifications.Notification>().WithMany().HasForeignKey(x => x.NotificationId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Notifications.DeviceRegistration>().WithMany().HasForeignKey(x => x.DeviceRegistrationId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.NotificationId, x.DeviceRegistrationId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_notification_deliveries_1", "attempt_count >= 0"));

    }
}
