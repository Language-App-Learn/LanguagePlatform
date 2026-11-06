using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class LessonConfiguration : IEntityTypeConfiguration<Lesson>
{
    public void Configure(EntityTypeBuilder<Lesson> builder)
    {
        ModelConventions.Configure(builder, "lessons");
        builder.Property(x => x.CourseUnitId).IsRequired();
        builder.Property(x => x.Slug).HasMaxLength(120).IsRequired();
        builder.Property(x => x.DisplayOrder).IsRequired();
        builder.Property(x => x.IsArchived).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.CourseUnit>().WithMany().HasForeignKey(x => x.CourseUnitId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CourseUnitId, x.Slug }).IsUnique();
        builder.HasIndex(x => new { x.CourseUnitId, x.DisplayOrder }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lessons_1", "display_order > 0"));

    }
}

