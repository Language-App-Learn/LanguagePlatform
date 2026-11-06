using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class WordFormConfiguration : IEntityTypeConfiguration<WordForm>
{
    public void Configure(EntityTypeBuilder<WordForm> builder)
    {
        ModelConventions.Configure(builder, "word_forms");
        builder.Property(x => x.DictionaryEntryId).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(250).IsRequired();
        builder.Property(x => x.NormalizedText).HasMaxLength(250).IsRequired();
        builder.Property(x => x.FormType).HasMaxLength(64).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Dictionary.DictionaryEntry>().WithMany().HasForeignKey(x => x.DictionaryEntryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.DictionaryEntryId, x.Text, x.FormType }).IsUnique();
        builder.HasIndex(x => x.NormalizedText);

    }
}

