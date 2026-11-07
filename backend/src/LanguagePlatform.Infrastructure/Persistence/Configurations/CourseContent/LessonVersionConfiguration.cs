using Microsoft.EntityFrameworkCore;
using LanguagePlatform.Domain.Common;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class LessonVersionConfiguration : IEntityTypeConfiguration<LessonVersion>
{
    public void Configure(EntityTypeBuilder<LessonVersion> builder)
    {
        ModelConventions.Configure(builder, "lesson_versions");
        builder.Property(x => x.LessonId).IsRequired();
        builder.Property(x => x.VersionNumber).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.PassingScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.AttemptSelection).HasConversion<string>().HasMaxLength(32).IsRequired();
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.PublishedAtUtc);
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.CourseContent.Lesson>().WithMany().HasForeignKey(x => x.LessonId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonId, x.VersionNumber }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_versions_1", "version_number > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_versions_2", "passing_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_versions_3", "(status = 'Published') = (published_at_utc IS NOT NULL)"));
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_versions_five_stage",
            "NOT uses_five_stage_curriculum OR (passing_score = 60 AND (status <> 'Published' OR weights_approved))"));

    }
}
