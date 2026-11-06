using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Catalog;

public sealed class CourseCategoryConfiguration : IEntityTypeConfiguration<CourseCategory>
{
    public void Configure(EntityTypeBuilder<CourseCategory> builder)
    {
        ModelConventions.Configure(builder, "course_categories");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.HasIndex(x => x.Code).IsUnique();

    }
}

