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
        builder.Property(x => x.ExtractedPagesJson).HasColumnType("jsonb");
        builder.HasIndex(x => x.LessonVersionId);
        builder.HasIndex(x => x.LessonVersionId, "UX_reading_materials_inline_pdf_version").IsUnique()
            .HasFilter("original_pdf IS NOT NULL");
        builder.ToTable(t => t.HasCheckConstraint("ck_reading_materials_inline_pdf",
            "original_pdf IS NULL OR (octet_length(original_pdf) BETWEEN 8 AND 2097152 AND extracted_pages_json IS NOT NULL)"));
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.PdfAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UploadedBy).OnDelete(DeleteBehavior.Restrict);

    }
}
