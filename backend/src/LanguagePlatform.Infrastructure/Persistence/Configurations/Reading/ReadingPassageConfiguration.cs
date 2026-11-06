using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingPassageConfiguration : IEntityTypeConfiguration<ReadingPassage>
{
    public void Configure(EntityTypeBuilder<ReadingPassage> builder)
    {
        ModelConventions.Configure(builder, "reading_passages");
        builder.Property(x => x.ReadingMaterialId).IsRequired();
        builder.Property(x => x.Sequence).IsRequired();
        builder.Property(x => x.OriginalText).HasMaxLength(64000).IsRequired();
        builder.Property(x => x.PageNumber);
        builder.HasOne<LanguagePlatform.Domain.Reading.ReadingMaterial>().WithMany().HasForeignKey(x => x.ReadingMaterialId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.ReadingMaterialId, x.Sequence }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_passages_1", "sequence > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_passages_2", "page_number IS NULL OR page_number > 0"));

    }
}

