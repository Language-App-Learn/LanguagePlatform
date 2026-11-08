using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Analytics;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Analytics;

public sealed class DailyCourseMetricConfiguration : IEntityTypeConfiguration<DailyCourseMetric>
{
    public void Configure(EntityTypeBuilder<DailyCourseMetric> builder)
    {
        ModelConventions.Configure(builder, "daily_course_metrics");
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.MetricDate).IsRequired();
        builder.Property(x => x.ActiveStudents).IsRequired();
        builder.Property(x => x.LessonsCompleted).IsRequired();
        builder.Property(x => x.AssessmentsCompleted).IsRequired();
        builder.Property(x => x.UpdatedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseId, x.MetricDate }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_daily_course_metrics_1", "active_students >= 0 AND lessons_completed >= 0 AND assessments_completed >= 0"));

    }
}
