using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class LessonLocalizationConfiguration : IEntityTypeConfiguration<LessonLocalization>
{
    public void Configure(EntityTypeBuilder<LessonLocalization> builder)
    {
        ModelConventions.Configure(builder, "lesson_localizations");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(4000);
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonVersionId, x.LanguageId }).IsUnique();

    }
}
