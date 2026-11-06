using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class MediaAccessPolicyConfiguration : IEntityTypeConfiguration<MediaAccessPolicy>
{
    public void Configure(EntityTypeBuilder<MediaAccessPolicy> builder)
    {
        ModelConventions.Configure(builder, "media_access_policies");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.IsPublic).IsRequired();
        builder.Property(x => x.RequiresEnrollment).IsRequired();
        builder.Property(x => x.RequiresEntitlement).IsRequired();
        builder.HasIndex(x => x.Code).IsUnique();

    }
}

