using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIEvaluationResultConfiguration : IEntityTypeConfiguration<AIEvaluationResult>
{
    public void Configure(EntityTypeBuilder<AIEvaluationResult> builder)
    {
        ModelConventions.Configure(builder, "ai_evaluation_results");
        builder.Property(x => x.AIEvaluationRequestId).IsRequired();
        builder.Property(x => x.PronunciationScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.FluencyScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.AccuracyScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.OverallScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Feedback).HasMaxLength(8000).IsRequired();
        builder.Property(x => x.ModelVersion).HasMaxLength(120).IsRequired();
        builder.Property(x => x.EvaluatedAtUtc).IsRequired();
        builder.Property(x => x.AcceptedForScoring).IsRequired();
        builder.Property(x => x.ReviewedBy);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIEvaluationRequest>().WithMany().HasForeignKey(x => x.AIEvaluationRequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.ReviewedBy).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.AIEvaluationRequestId).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_results_1", "pronunciation_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_results_2", "fluency_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_results_3", "accuracy_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_results_4", "overall_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_evaluation_results_5", "NOT accepted_for_scoring OR reviewed_by IS NOT NULL"));

    }
}
