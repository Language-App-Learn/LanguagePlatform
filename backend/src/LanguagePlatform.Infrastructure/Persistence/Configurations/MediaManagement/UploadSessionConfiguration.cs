using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class UploadSessionConfiguration : IEntityTypeConfiguration<UploadSession>
{
    public void Configure(EntityTypeBuilder<UploadSession> builder)
    {
        ModelConventions.Configure(builder, "upload_sessions");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.MediaAssetId);
        builder.Property(x => x.StorageKey).HasMaxLength(512).IsRequired();
        builder.Property(x => x.MaximumBytes).IsRequired();
        builder.Property(x => x.ExpectedContentType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.Property(x => x.CompletedAtUtc);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.StorageKey).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_upload_sessions_1", "maximum_bytes > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_upload_sessions_2", "expires_at_utc > created_at_utc"));

    }
}
