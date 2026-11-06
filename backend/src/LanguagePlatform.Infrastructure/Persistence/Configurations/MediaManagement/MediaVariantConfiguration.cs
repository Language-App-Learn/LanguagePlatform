using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class MediaVariantConfiguration : IEntityTypeConfiguration<MediaVariant>
{
    public void Configure(EntityTypeBuilder<MediaVariant> builder)
    {
        ModelConventions.Configure(builder, "media_variants");
        builder.Property(x => x.MediaAssetId).IsRequired();
        builder.Property(x => x.VariantType).HasMaxLength(64).IsRequired();
        builder.Property(x => x.StorageKey).HasMaxLength(512).IsRequired();
        builder.Property(x => x.ContentType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.FileSize).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.MediaAssetId, x.VariantType }).IsUnique();
        builder.HasIndex(x => x.StorageKey).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_media_variants_1", "file_size > 0"));

    }
}

