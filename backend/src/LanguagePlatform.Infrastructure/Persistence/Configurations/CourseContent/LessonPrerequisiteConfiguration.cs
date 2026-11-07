using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class LessonPrerequisiteConfiguration : IEntityTypeConfiguration<LessonPrerequisite>
{
    public void Configure(EntityTypeBuilder<LessonPrerequisite> builder)
    {
        ModelConventions.Configure(builder, "lesson_prerequisites");
        builder.Property(x => x.LessonId).IsRequired();
        builder.Property(x => x.RequiredLessonId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.Lesson>().WithMany().HasForeignKey(x => x.LessonId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.CourseContent.Lesson>().WithMany().HasForeignKey(x => x.RequiredLessonId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonId, x.RequiredLessonId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_prerequisites_1", "lesson_id <> required_lesson_id"));

    }
}
