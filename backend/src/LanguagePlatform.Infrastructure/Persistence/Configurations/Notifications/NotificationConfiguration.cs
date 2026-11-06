using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Notifications;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Notifications;

public sealed class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        ModelConventions.Configure(builder, "notifications");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.TemplateId).IsRequired();
        builder.Property(x => x.PayloadSchemaVersion).IsRequired();
        builder.Property(x => x.PayloadJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.ReadAtUtc);
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Notifications.NotificationTemplate>().WithMany().HasForeignKey(x => x.TemplateId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.UserId, x.CreatedAtUtc });
        builder.ToTable(t => t.HasCheckConstraint("ck_notifications_1", "payload_schema_version > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_notifications_2", "expires_at_utc > created_at_utc"));

    }
}

