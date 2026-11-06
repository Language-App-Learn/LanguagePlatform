using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIProcessingJobConfiguration : IEntityTypeConfiguration<AIProcessingJob>
{
    public void Configure(EntityTypeBuilder<AIProcessingJob> builder)
    {
        ModelConventions.Configure(builder, "ai_processing_jobs");
        builder.Property(x => x.AIEvaluationRequestId).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.AttemptCount).IsRequired();
        builder.Property(x => x.AvailableAtUtc).IsRequired();
        builder.Property(x => x.LeaseUntilUtc);
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.ErrorCode).HasMaxLength(80);
        builder.Property(x => x.CorrelationId).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIEvaluationRequest>().WithMany().HasForeignKey(x => x.AIEvaluationRequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.AIEvaluationRequestId).IsUnique();
        builder.HasIndex(x => new { x.Status, x.AvailableAtUtc });
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_processing_jobs_1", "attempt_count >= 0"));

    }
}

