using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class QuestionBankConfiguration : IEntityTypeConfiguration<QuestionBank>
{
    public void Configure(EntityTypeBuilder<QuestionBank> builder)
    {
        ModelConventions.Configure(builder, "question_banks");
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.OwnerId).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.OwnerId).OnDelete(DeleteBehavior.Restrict);

    }
}

