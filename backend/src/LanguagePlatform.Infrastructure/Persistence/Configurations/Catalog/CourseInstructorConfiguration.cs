using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Catalog;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Catalog;

public sealed class CourseInstructorConfiguration : IEntityTypeConfiguration<CourseInstructor>
{
    public void Configure(EntityTypeBuilder<CourseInstructor> builder)
    {
        ModelConventions.Configure(builder, "course_instructors");
        builder.Property(x => x.CourseId).IsRequired();
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.CanEdit).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Course>().WithMany().HasForeignKey(x => x.CourseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseId, x.UserId }).IsUnique();

    }
}

