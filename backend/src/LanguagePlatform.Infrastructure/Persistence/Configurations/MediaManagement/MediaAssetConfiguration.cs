using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class MediaAssetConfiguration : IEntityTypeConfiguration<MediaAsset>
{
    public void Configure(EntityTypeBuilder<MediaAsset> builder)
    {
        ModelConventions.Configure(builder, "media_assets");
        builder.Property(x => x.StorageKey).HasMaxLength(512).IsRequired();
        builder.Property(x => x.ContentType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.FileSize).IsRequired();
        builder.Property(x => x.Checksum).HasMaxLength(128).IsRequired();
        builder.Property(x => x.OriginalFileName).HasMaxLength(255).IsRequired();
        builder.Property(x => x.UploadedBy).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.AccessPolicyId).IsRequired();
        builder.Property(x => x.License).HasMaxLength(512);
        builder.Property(x => x.RightsHolder).HasMaxLength(200);
        builder.Property(x => x.RightsConfirmedAtUtc);
        builder.Property(x => x.DeletedAtUtc);
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UploadedBy).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAccessPolicy>().WithMany().HasForeignKey(x => x.AccessPolicyId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.StorageKey).IsUnique();
        builder.HasIndex(x => new { x.UploadedBy, x.CreatedAtUtc });
        builder.ToTable(t => t.HasCheckConstraint("ck_media_assets_1", "file_size > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_media_assets_2", "status IN ('PendingScan','Ready','Rejected','Deleted')"));
        builder.HasQueryFilter(x => x.DeletedAtUtc == null);

    }
}
