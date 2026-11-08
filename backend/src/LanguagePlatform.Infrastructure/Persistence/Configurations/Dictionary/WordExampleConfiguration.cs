using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class WordExampleConfiguration : IEntityTypeConfiguration<WordExample>
{
    public void Configure(EntityTypeBuilder<WordExample> builder)
    {
        ModelConventions.Configure(builder, "word_examples");
        builder.Property(x => x.WordSenseId).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(4000).IsRequired();
        builder.Property(x => x.SourceAttribution).HasMaxLength(1000);
        builder.Property(x => x.VideoId).HasMaxLength(32);
        builder.Property(x => x.StartSeconds);
        builder.Property(x => x.EndSeconds);
        builder.HasOne<LanguagePlatform.Domain.Dictionary.WordSense>().WithMany().HasForeignKey(x => x.WordSenseId).OnDelete(DeleteBehavior.Restrict);
        builder.ToTable(t => t.HasCheckConstraint("ck_word_examples_1", "start_seconds IS NULL OR start_seconds >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_word_examples_2", "end_seconds IS NULL OR (start_seconds IS NOT NULL AND end_seconds > start_seconds)"));

    }
}
