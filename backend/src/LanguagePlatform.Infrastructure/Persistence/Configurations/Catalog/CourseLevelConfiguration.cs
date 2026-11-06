using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Catalog;

public sealed class CourseLevelConfiguration : IEntityTypeConfiguration<CourseLevel>
{
    public void Configure(EntityTypeBuilder<CourseLevel> builder)
    {
        ModelConventions.Configure(builder, "course_levels");
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseId, x.Code }).IsUnique();
        builder.HasIndex(x => new { x.CourseId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_course_levels_1", "display_order > 0"));

    }
}

