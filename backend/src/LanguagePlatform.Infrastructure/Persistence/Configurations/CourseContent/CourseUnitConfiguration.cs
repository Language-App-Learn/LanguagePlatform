using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class CourseUnitConfiguration : IEntityTypeConfiguration<CourseUnit>
{
    public void Configure(EntityTypeBuilder<CourseUnit> builder)
    {
        ModelConventions.Configure(builder, "course_units");
        builder.Property(x => x.CourseModuleId).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.CourseModule>().WithMany().HasForeignKey(x => x.CourseModuleId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseModuleId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_course_units_1", "display_order > 0"));

    }
}
