using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class DictionaryEntryConfiguration : IEntityTypeConfiguration<DictionaryEntry>
{
    public void Configure(EntityTypeBuilder<DictionaryEntry> builder)
    {
        ModelConventions.Configure(builder, "dictionary_entries");
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.RootId);
        builder.Property(x => x.Lemma).HasMaxLength(250).IsRequired();
        builder.Property(x => x.NormalizedLemma).HasMaxLength(250).IsRequired();
        builder.Property(x => x.PartOfSpeech).HasMaxLength(64).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Dictionary.Root>().WithMany().HasForeignKey(x => x.RootId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LanguageId, x.Lemma, x.PartOfSpeech }).IsUnique();
        builder.HasIndex(x => new { x.LanguageId, x.NormalizedLemma });

    }
}

