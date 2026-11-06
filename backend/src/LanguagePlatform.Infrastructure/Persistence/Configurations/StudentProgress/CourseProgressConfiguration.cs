using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class CourseProgressConfiguration : IEntityTypeConfiguration<CourseProgress>
{
    public void Configure(EntityTypeBuilder<CourseProgress> builder)
    {
        ModelConventions.Configure(builder, "course_progress");
        builder.Property(x => x.EnrollmentId).IsRequired();
        builder.Property(x => x.CompletedLessonCount).IsRequired();
        builder.Property(x => x.UpdatedAtUtc).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.Enrollment>().WithMany().HasForeignKey(x => x.EnrollmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.EnrollmentId).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_course_progress_1", "completed_lesson_count >= 0"));

    }
}

