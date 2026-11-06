using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class LessonProgressConfiguration : IEntityTypeConfiguration<LessonProgress>
{
    public void Configure(EntityTypeBuilder<LessonProgress> builder)
    {
        ModelConventions.Configure(builder, "lesson_progress");
        builder.Property(x => x.EnrollmentId).IsRequired();
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.Score).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.IsPassed).IsRequired();
        builder.Property(x => x.UpdatedAtUtc).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.Enrollment>().WithMany().HasForeignKey(x => x.EnrollmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.EnrollmentId, x.LessonVersionId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_progress_1", "score BETWEEN 0 AND 100"));
        builder.HasAlternateKey(x => new { x.Id, x.LessonVersionId });

    }
}

