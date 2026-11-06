using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Catalog;

public sealed class CoursePrerequisiteConfiguration : IEntityTypeConfiguration<CoursePrerequisite>
{
    public void Configure(EntityTypeBuilder<CoursePrerequisite> builder)
    {
        ModelConventions.Configure(builder, "course_prerequisites");
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.RequiredCourseId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.RequiredCourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseId, x.RequiredCourseId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_course_prerequisites_1", "course_id <> required_course_id"));

    }
}

