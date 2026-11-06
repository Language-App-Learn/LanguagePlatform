using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class WordTranslationConfiguration : IEntityTypeConfiguration<WordTranslation>
{
    public void Configure(EntityTypeBuilder<WordTranslation> builder)
    {
        ModelConventions.Configure(builder, "word_translations");
        builder.Property(x => x.WordSenseId).IsRequired();
        builder.Property(x => x.TargetLanguageId).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(1000).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Dictionary.WordSense>().WithMany().HasForeignKey(x => x.WordSenseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.TargetLanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.WordSenseId, x.TargetLanguageId, x.Text }).IsUnique();

    }
}

