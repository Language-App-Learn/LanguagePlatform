using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class WordSenseConfiguration : IEntityTypeConfiguration<WordSense>
{
    public void Configure(EntityTypeBuilder<WordSense> builder)
    {
        ModelConventions.Configure(builder, "word_senses");
        builder.Property(x => x.DictionaryEntryId).IsRequired();
        builder.Property(x => x.SenseNumber).IsRequired();
        builder.Property(x => x.Definition).HasMaxLength(4000).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Dictionary.DictionaryEntry>().WithMany().HasForeignKey(x => x.DictionaryEntryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.DictionaryEntryId, x.SenseNumber }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_word_senses_1", "sense_number > 0"));

    }
}
