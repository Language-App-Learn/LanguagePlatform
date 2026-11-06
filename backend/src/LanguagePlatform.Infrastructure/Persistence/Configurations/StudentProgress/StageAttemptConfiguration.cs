using Microsoft.EntityFrameworkCore;
using LanguagePlatform.Domain.Common;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class StageAttemptConfiguration : IEntityTypeConfiguration<StageAttempt>
{
    public void Configure(EntityTypeBuilder<StageAttempt> builder)
    {
        ModelConventions.Configure(builder, "stage_attempts");
        builder.Property(x => x.StageProgressId).IsRequired();
        builder.Property(x => x.AttemptNumber).IsRequired();
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
        builder.Property(x => x.Score).HasPrecision(18, 4);
        builder.Property(x => x.StartedAtUtc).IsRequired();
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.StageProgress>().WithMany().HasForeignKey(x => x.StageProgressId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StageProgressId, x.AttemptNumber }).IsUnique();
        builder.HasIndex(x => new { x.StageProgressId, x.IdempotencyKey }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_stage_attempts_1", "attempt_number > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_stage_attempts_2", "score IS NULL OR score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_stage_attempts_3", "completed_at_utc IS NULL OR completed_at_utc >= started_at_utc"));

    }
}

