using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.LessonEngine;

public sealed class LessonStageContentConfiguration : IEntityTypeConfiguration<LessonStageContent>
{
    public void Configure(EntityTypeBuilder<LessonStageContent> builder)
    {
        ModelConventions.Configure(builder, "lesson_stage_contents");
        builder.Property(x => x.LessonStageId).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.Body).HasMaxLength(64000);
        builder.Property(x => x.MediaAssetId);
        builder.HasOne<LanguagePlatform.Domain.LessonEngine.LessonStage>().WithMany().HasForeignKey(x => x.LessonStageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.MediaAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.LessonStageId, x.LanguageId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_lesson_stage_contents_1", "body IS NOT NULL OR media_asset_id IS NOT NULL"));

    }
}

