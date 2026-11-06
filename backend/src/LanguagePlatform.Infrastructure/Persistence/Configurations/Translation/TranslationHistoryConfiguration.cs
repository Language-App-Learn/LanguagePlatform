using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Translation;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Translation;

public sealed class TranslationHistoryConfiguration : IEntityTypeConfiguration<TranslationHistory>
{
    public void Configure(EntityTypeBuilder<TranslationHistory> builder)
    {
        ModelConventions.Configure(builder, "translation_history");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.SourceLanguageId).IsRequired();
        builder.Property(x => x.TargetLanguageId).IsRequired();
        builder.Property(x => x.SourceText).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.TranslatedText).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.Context).HasMaxLength(4000);
        builder.Property(x => x.ProviderModel).HasMaxLength(120).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.SourceLanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.TargetLanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.CreatedAtUtc });
        builder.HasIndex(x => x.ExpiresAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_translation_history_1", "source_language_id <> target_language_id"));
        builder.ToTable(t => t.HasCheckConstraint("ck_translation_history_2", "expires_at_utc > created_at_utc"));

    }
}

