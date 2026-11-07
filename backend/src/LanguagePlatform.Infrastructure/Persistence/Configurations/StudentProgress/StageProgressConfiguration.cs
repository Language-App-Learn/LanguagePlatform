using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class StageProgressConfiguration : IEntityTypeConfiguration<StageProgress>
{
    public void Configure(EntityTypeBuilder<StageProgress> builder)
    {
        ModelConventions.Configure(builder, "stage_progress");
        builder.Property(x => x.LessonProgressId).IsRequired();
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.LessonStageId).IsRequired();
        builder.Property(x => x.Score).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.IsCompleted).IsRequired();
        builder.Property(x => x.UpdatedAtUtc).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasIndex(x => new { x.LessonProgressId, x.LessonStageId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_stage_progress_1", "score BETWEEN 0 AND 100"));
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.LessonProgress>().WithMany().HasForeignKey(x => new { x.LessonProgressId, x.LessonVersionId }).HasPrincipalKey(x => new { x.Id, x.LessonVersionId }).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.LessonEngine.LessonStage>().WithMany().HasForeignKey(x => new { x.LessonStageId, x.LessonVersionId }).HasPrincipalKey(x => new { x.Id, x.LessonVersionId }).OnDelete(DeleteBehavior.Restrict);

    }
}
