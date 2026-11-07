using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class AnswerEvaluationConfiguration : IEntityTypeConfiguration<AnswerEvaluation>
{
    public void Configure(EntityTypeBuilder<AnswerEvaluation> builder)
    {
        ModelConventions.Configure(builder, "answer_evaluations");
        builder.Property(x => x.StudentAnswerId).IsRequired();
        builder.Property(x => x.ScoringRubricId).IsRequired();
        builder.Property(x => x.EvaluatorId);
        builder.Property(x => x.Score).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Feedback).HasMaxLength(8000);
        builder.Property(x => x.EvaluatedAtUtc).IsRequired();
        builder.Property(x => x.Method).HasMaxLength(32).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.StudentAnswer>().WithMany().HasForeignKey(x => x.StudentAnswerId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Assessment.ScoringRubric>().WithMany().HasForeignKey(x => x.ScoringRubricId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.EvaluatorId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.StudentAnswerId).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_answer_evaluations_1", "score >= 0"));

    }
}
