using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.MediaManagement;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.MediaManagement;

public sealed class MediaProcessingJobConfiguration : IEntityTypeConfiguration<MediaProcessingJob>
{
    public void Configure(EntityTypeBuilder<MediaProcessingJob> builder)
    {
        ModelConventions.Configure(builder, "media_processing_jobs");
        builder.Property(x => x.MediaAssetId).IsRequired();
        builder.Property(x => x.Operation).HasMaxLength(64).IsRequired();
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.AttemptCount).IsRequired();
        builder.Property(x => x.AvailableAtUtc).IsRequired();
        builder.Property(x => x.LeaseUntilUtc);
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.ErrorCode).HasMaxLength(80);
        builder.Property(x => x.CorrelationId).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.IdempotencyKey).IsUnique();
        builder.HasIndex(x => new { x.Status, x.AvailableAtUtc });
        builder.ToTable(t => t.HasCheckConstraint("ck_media_processing_jobs_1", "attempt_count >= 0"));

    }
}
