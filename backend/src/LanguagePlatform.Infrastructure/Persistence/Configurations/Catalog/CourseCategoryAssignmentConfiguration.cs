using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Catalog;

public sealed class CourseCategoryAssignmentConfiguration : IEntityTypeConfiguration<CourseCategoryAssignment>
{
    public void Configure(EntityTypeBuilder<CourseCategoryAssignment> builder)
    {
        ModelConventions.Configure(builder, "course_category_assignments");
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.CourseCategoryId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.CourseCategory>().WithMany().HasForeignKey(x => x.CourseCategoryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseId, x.CourseCategoryId }).IsUnique();

    }
}
