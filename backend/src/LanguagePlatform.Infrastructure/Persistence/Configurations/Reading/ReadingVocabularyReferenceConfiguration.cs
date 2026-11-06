using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingVocabularyReferenceConfiguration : IEntityTypeConfiguration<ReadingVocabularyReference>
{
    public void Configure(EntityTypeBuilder<ReadingVocabularyReference> builder)
    {
        ModelConventions.Configure(builder, "reading_vocabulary_references");
        builder.Property(x => x.ReadingTextSegmentId).IsRequired();
        builder.Property(x => x.DictionaryEntryId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Reading.ReadingTextSegment>().WithMany().HasForeignKey(x => x.ReadingTextSegmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Dictionary.DictionaryEntry>().WithMany().HasForeignKey(x => x.DictionaryEntryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.ReadingTextSegmentId, x.DictionaryEntryId }).IsUnique();

    }
}

