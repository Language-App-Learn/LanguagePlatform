using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations;

public sealed class LanguageConfiguration : IEntityTypeConfiguration<Language>
{
    public void Configure(EntityTypeBuilder<Language> builder)
    {
        builder.ToTable("languages");
        builder.HasKey(language => language.Id).HasName("pk_languages");

        builder.Property(language => language.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(language => language.Code)
            .HasColumnName("code")
            .HasConversion(code => code.Value, value => LanguageCode.Create(value))
            .HasMaxLength(LanguageCode.MaxLength)
            .IsRequired();
        builder.Property(language => language.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
        builder.Property(language => language.NativeName).HasColumnName("native_name").HasMaxLength(100).IsRequired();
        builder.Property(language => language.TextDirection).HasColumnName("text_direction").HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.Property(language => language.IsActive).HasColumnName("is_active").IsRequired();

        builder.HasIndex(language => language.Code).IsUnique().HasDatabaseName("ux_languages_code");
    }
}
