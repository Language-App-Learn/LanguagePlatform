using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class LearningActivityConfiguration : IEntityTypeConfiguration<LearningActivity>
{
    public void Configure(EntityTypeBuilder<LearningActivity> builder)
    {
        ModelConventions.Configure(builder, "learning_activities");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.EnrollmentId);
        builder.Property(x => x.ActivityType).HasMaxLength(64).IsRequired();
        builder.Property(x => x.OccurredAtUtc).IsRequired();
        builder.Property(x => x.DurationSeconds).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.Enrollment>().WithMany().HasForeignKey(x => x.EnrollmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.OccurredAtUtc });
        builder.ToTable(t => t.HasCheckConstraint("ck_learning_activities_1", "duration_seconds >= 0"));

    }
}

