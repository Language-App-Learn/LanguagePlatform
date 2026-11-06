using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingSessionConfiguration : IEntityTypeConfiguration<ReadingSession>
{
    public void Configure(EntityTypeBuilder<ReadingSession> builder)
    {
        ModelConventions.Configure(builder, "reading_sessions");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.ReadingMaterialId).IsRequired();
        builder.Property(x => x.StartedAtUtc).IsRequired();
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.AudioAssetId);
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Reading.ReadingMaterial>().WithMany().HasForeignKey(x => x.ReadingMaterialId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.AudioAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.StartedAtUtc });
        builder.HasIndex(x => x.ExpiresAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_sessions_1", "expires_at_utc > started_at_utc"));

    }
}

