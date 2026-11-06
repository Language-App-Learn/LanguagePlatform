using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Notifications;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Notifications;

public sealed class NotificationTemplateConfiguration : IEntityTypeConfiguration<NotificationTemplate>
{
    public void Configure(EntityTypeBuilder<NotificationTemplate> builder)
    {
        ModelConventions.Configure(builder, "notification_templates");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Body).HasMaxLength(4000).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Code, x.LanguageId }).IsUnique();

    }
}

