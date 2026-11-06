using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class RootConfiguration : IEntityTypeConfiguration<Root>
{
    public void Configure(EntityTypeBuilder<Root> builder)
    {
        ModelConventions.Configure(builder, "dictionary_roots");
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.Letters).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Meaning).HasMaxLength(1000);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LanguageId, x.Letters }).IsUnique();

    }
}

