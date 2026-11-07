using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class PronunciationConfiguration : IEntityTypeConfiguration<Pronunciation>
{
    public void Configure(EntityTypeBuilder<Pronunciation> builder)
    {
        ModelConventions.Configure(builder, "pronunciations");
        builder.Property(x => x.DictionaryEntryId).IsRequired();
        builder.Property(x => x.MediaAssetId).IsRequired();
        builder.Property(x => x.DialectCode).HasMaxLength(35).IsRequired();
        builder.Property(x => x.PhoneticText).HasMaxLength(1000);
        builder.HasOne<LanguagePlatform.Domain.Dictionary.DictionaryEntry>().WithMany().HasForeignKey(x => x.DictionaryEntryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.DictionaryEntryId, x.MediaAssetId }).IsUnique();

    }
}
