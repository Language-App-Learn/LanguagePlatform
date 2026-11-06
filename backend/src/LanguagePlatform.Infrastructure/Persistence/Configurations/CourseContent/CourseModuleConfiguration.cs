using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class CourseModuleConfiguration : IEntityTypeConfiguration<CourseModule>
{
    public void Configure(EntityTypeBuilder<CourseModule> builder)
    {
        ModelConventions.Configure(builder, "course_modules");
        builder.Property(x => x.CourseLevelId).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.CourseLevel>().WithMany().HasForeignKey(x => x.CourseLevelId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseLevelId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_course_modules_1", "display_order > 0"));

    }
}

