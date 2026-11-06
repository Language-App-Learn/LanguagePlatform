using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIEvaluationRequestConfiguration : IEntityTypeConfiguration<AIEvaluationRequest>
{
    public void Configure(EntityTypeBuilder<AIEvaluationRequest> builder)
    {
        ModelConventions.Configure(builder, "ai_evaluation_requests");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.StageAttemptId);
        builder.Property(x => x.AudioAssetId).IsRequired();
        builder.Property(x => x.ProviderConfigurationId).IsRequired();
        builder.Property(x => x.ScoringRubricId).IsRequired();
        builder.Property(x => x.ReferenceText).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.StageAttempt>().WithMany().HasForeignKey(x => x.StageAttemptId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.AudioAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIProviderConfiguration>().WithMany().HasForeignKey(x => x.ProviderConfigurationId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Assessment.ScoringRubric>().WithMany().HasForeignKey(x => x.ScoringRubricId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.IdempotencyKey }).IsUnique();
        builder.HasIndex(x => x.ExpiresAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_requests_1", "expires_at_utc > created_at_utc"));

    }
}

