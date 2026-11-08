using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations;

public sealed class LearningPathConfiguration : IEntityTypeConfiguration<LearningPath>
{
    public void Configure(EntityTypeBuilder<LearningPath> builder)
    {
        builder.ToTable("learning_paths", table =>
            table.HasCheckConstraint("ck_learning_paths_distinct_languages", "source_language_id <> target_language_id"));
        builder.HasKey(path => path.Id).HasName("pk_learning_paths");

        builder.Property(path => path.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(path => path.SourceLanguageId).HasColumnName("source_language_id").IsRequired();
        builder.Property(path => path.TargetLanguageId).HasColumnName("target_language_id").IsRequired();
        builder.Property(path => path.IsActive).HasColumnName("is_active").IsRequired();

        builder.HasIndex(path => new { path.SourceLanguageId, path.TargetLanguageId })
            .IsUnique()
            .HasDatabaseName("ux_learning_paths_direction");

        builder.HasOne(path => path.SourceLanguage)
            .WithMany()
            .HasForeignKey(path => path.SourceLanguageId)
            .OnDelete(DeleteBehavior.Restrict)
            .HasConstraintName("fk_learning_paths_source_language");
        builder.HasOne(path => path.TargetLanguage)
            .WithMany()
            .HasForeignKey(path => path.TargetLanguageId)
            .OnDelete(DeleteBehavior.Restrict)
            .HasConstraintName("fk_learning_paths_target_language");
    }
}
