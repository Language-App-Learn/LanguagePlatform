using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class QuestionLocalizationConfiguration : IEntityTypeConfiguration<QuestionLocalization>
{
    public void Configure(EntityTypeBuilder<QuestionLocalization> builder)
    {
        ModelConventions.Configure(builder, "question_localizations");
        builder.Property(x => x.QuestionId).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.Prompt).HasMaxLength(16000).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.Question>().WithMany().HasForeignKey(x => x.QuestionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.QuestionId, x.LanguageId }).IsUnique();

    }
}

