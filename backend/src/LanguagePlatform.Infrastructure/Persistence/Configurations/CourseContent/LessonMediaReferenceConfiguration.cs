using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class LessonMediaReferenceConfiguration : IEntityTypeConfiguration<LessonMediaReference>
{
    public void Configure(EntityTypeBuilder<LessonMediaReference> builder)
    {
        ModelConventions.Configure(builder, "lesson_media_references");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.MediaAssetId).IsRequired();
        builder.Property(x => x.Purpose).HasMaxLength(64).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonVersionId, x.MediaAssetId, x.Purpose }).IsUnique();

    }
}

