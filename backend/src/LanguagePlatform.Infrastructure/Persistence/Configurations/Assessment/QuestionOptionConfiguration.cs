using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class QuestionOptionConfiguration : IEntityTypeConfiguration<QuestionOption>
{
    public void Configure(EntityTypeBuilder<QuestionOption> builder)
    {
        ModelConventions.Configure(builder, "question_options");
        builder.Property(x => x.QuestionId).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.IsCorrect).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.Question>().WithMany().HasForeignKey(x => x.QuestionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.QuestionId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_question_options_1", "display_order > 0"));

    }
}
