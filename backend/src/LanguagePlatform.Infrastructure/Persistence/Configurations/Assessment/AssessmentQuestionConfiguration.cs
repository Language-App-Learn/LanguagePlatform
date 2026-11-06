using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class AssessmentQuestionConfiguration : IEntityTypeConfiguration<AssessmentQuestion>
{
    public void Configure(EntityTypeBuilder<AssessmentQuestion> builder)
    {
        ModelConventions.Configure(builder, "assessment_questions");
        builder.Property(x => x.AssessmentId).IsRequired();
        builder.Property(x => x.QuestionId).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.Property(x => x.MaximumScore).HasPrecision(18, 4).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.Assessment>().WithMany().HasForeignKey(x => x.AssessmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Assessment.Question>().WithMany().HasForeignKey(x => x.QuestionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.AssessmentId, x.DisplayOrder }).IsUnique();
        builder.HasIndex(x => new { x.AssessmentId, x.QuestionId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_questions_1", "display_order > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_questions_2", "maximum_score > 0"));

    }
}

