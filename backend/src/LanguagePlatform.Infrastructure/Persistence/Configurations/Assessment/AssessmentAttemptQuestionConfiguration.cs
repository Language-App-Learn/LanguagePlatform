using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class AssessmentAttemptQuestionConfiguration : IEntityTypeConfiguration<AssessmentAttemptQuestion>
{
    public void Configure(EntityTypeBuilder<AssessmentAttemptQuestion> builder)
    {
        ModelConventions.Configure(builder, "assessment_attempt_questions");
        builder.Property(x => x.AssessmentAttemptId).IsRequired();
        builder.Property(x => x.QuestionId).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.Property(x => x.PromptSnapshot).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.AnswerKeySnapshotJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.OptionsSnapshotJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.MaximumScore).HasPrecision(18, 4).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.AssessmentAttempt>().WithMany().HasForeignKey(x => x.AssessmentAttemptId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Assessment.Question>().WithMany().HasForeignKey(x => x.QuestionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.AssessmentAttemptId, x.DisplayOrder }).IsUnique();
        builder.HasIndex(x => new { x.AssessmentAttemptId, x.QuestionId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_attempt_questions_1", "maximum_score > 0"));

    }
}
