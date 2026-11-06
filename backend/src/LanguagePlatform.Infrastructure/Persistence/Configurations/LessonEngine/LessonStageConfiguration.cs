using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.LessonEngine;

public sealed class LessonStageConfiguration : IEntityTypeConfiguration<LessonStage>
{
    public void Configure(EntityTypeBuilder<LessonStage> builder)
    {
        ModelConventions.Configure(builder, "lesson_stages");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.StageType).HasMaxLength(64).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.Property(x => x.Weight).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.IsRequired).IsRequired();
        builder.Property(x => x.MinimumScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.MaximumAttempts).IsRequired();
        builder.Property(x => x.EstimatedDurationSeconds).IsRequired();
        builder.Property(x => x.SettingsSchemaVersion).IsRequired();
        builder.Property(x => x.SettingsJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonVersionId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_1", "display_order > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_2", "weight BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_3", "minimum_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_4", "maximum_attempts > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_5", "estimated_duration_seconds >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stages_6", "settings_schema_version > 0"));
        builder.HasAlternateKey(x => new { x.Id, x.LessonVersionId });

    }
}

