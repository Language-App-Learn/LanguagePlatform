using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class QuestionConfiguration : IEntityTypeConfiguration<Question>
{
    public void Configure(EntityTypeBuilder<Question> builder)
    {
        ModelConventions.Configure(builder, "questions");
        builder.Property(x => x.QuestionBankId).IsRequired();
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.VersionNumber).IsRequired();
        builder.Property(x => x.QuestionType).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Prompt).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.AnswerKeyJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.IsArchived).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.QuestionBank>().WithMany().HasForeignKey(x => x.QuestionBankId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.QuestionBankId, x.Code, x.VersionNumber }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_questions_1", "version_number > 0"));

    }
}

