using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingMaterialConfiguration : IEntityTypeConfiguration<ReadingMaterial>
{
    public void Configure(EntityTypeBuilder<ReadingMaterial> builder)
    {
        ModelConventions.Configure(builder, "reading_materials");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.PdfAssetId);
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.CopyrightNotice).HasMaxLength(2000).IsRequired();
        builder.Property(x => x.UploadedBy).IsRequired();
        builder.Property(x => x.RightsConfirmedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.PdfAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UploadedBy).OnDelete(DeleteBehavior.Restrict);

    }
}

