using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class StudentAnswerConfiguration : IEntityTypeConfiguration<StudentAnswer>
{
    public void Configure(EntityTypeBuilder<StudentAnswer> builder)
    {
        ModelConventions.Configure(builder, "student_answers");
        builder.Property(x => x.AttemptQuestionId).IsRequired();
        builder.Property(x => x.AnswerText).HasMaxLength(16000);
        builder.Property(x => x.SelectedOptionsJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.SubmittedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.AssessmentAttemptQuestion>().WithMany().HasForeignKey(x => x.AttemptQuestionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.AttemptQuestionId).IsUnique();

    }
}
