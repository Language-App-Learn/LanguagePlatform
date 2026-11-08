using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class MediaUsageConfiguration : IEntityTypeConfiguration<MediaUsage>
{
    public void Configure(EntityTypeBuilder<MediaUsage> builder)
    {
        ModelConventions.Configure(builder, "media_usages");
        builder.Property(x => x.MediaAssetId).IsRequired();
        builder.Property(x => x.Purpose).HasMaxLength(64).IsRequired();
        builder.Property(x => x.UsedByUserId).IsRequired();
        builder.Property(x => x.RecordedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UsedByUserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.MediaAssetId, x.RecordedAtUtc });

    }
}
