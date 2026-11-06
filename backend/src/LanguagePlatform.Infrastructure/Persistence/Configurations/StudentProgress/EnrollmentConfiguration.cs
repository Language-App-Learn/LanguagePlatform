using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class EnrollmentConfiguration : IEntityTypeConfiguration<Enrollment>
{
    public void Configure(EntityTypeBuilder<Enrollment> builder)
    {
        ModelConventions.Configure(builder, "enrollments");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.EnrolledAtUtc).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.CourseId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_enrollments_1", "status IN ('Active','Completed','Withdrawn')"));
        builder.ToTable(t => t.HasCheckConstraint("ck_enrollments_2", "completed_at_utc IS NULL OR completed_at_utc >= enrolled_at_utc"));

    }
}

