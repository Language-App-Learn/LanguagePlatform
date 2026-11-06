using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingTextSegmentConfiguration : IEntityTypeConfiguration<ReadingTextSegment>
{
    public void Configure(EntityTypeBuilder<ReadingTextSegment> builder)
    {
        ModelConventions.Configure(builder, "reading_text_segments");
        builder.Property(x => x.ReadingPassageId).IsRequired();
        builder.Property(x => x.Sequence).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(2000).IsRequired();
        builder.Property(x => x.StartOffset).IsRequired();
        builder.Property(x => x.Length).IsRequired();
        builder.Property(x => x.AlignmentSchemaVersion).IsRequired();
        builder.Property(x => x.AlignmentJson).HasColumnType("jsonb").IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Reading.ReadingPassage>().WithMany().HasForeignKey(x => x.ReadingPassageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.ReadingPassageId, x.Sequence }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_text_segments_1", "sequence > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_text_segments_2", "start_offset >= 0 AND length > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_text_segments_3", "alignment_schema_version > 0"));

    }
}

