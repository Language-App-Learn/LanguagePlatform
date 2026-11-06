using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Notifications;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Notifications;

public sealed class DeviceRegistrationConfiguration : IEntityTypeConfiguration<DeviceRegistration>
{
    public void Configure(EntityTypeBuilder<DeviceRegistration> builder)
    {
        ModelConventions.Configure(builder, "device_registrations");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.Platform).HasMaxLength(16).IsRequired();
        builder.Property(x => x.TokenHash).HasMaxLength(128).IsRequired();
        builder.Property(x => x.TokenCiphertext).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.RegisteredAtUtc).IsRequired();
        builder.Property(x => x.LastSeenAtUtc).IsRequired();
        builder.Property(x => x.RevokedAtUtc);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.TokenHash).IsUnique();
        builder.HasIndex(x => x.UserId);
        builder.ToTable(t => t.HasCheckConstraint("ck_device_registrations_1", "platform IN ('Android','iOS')"));

    }
}

