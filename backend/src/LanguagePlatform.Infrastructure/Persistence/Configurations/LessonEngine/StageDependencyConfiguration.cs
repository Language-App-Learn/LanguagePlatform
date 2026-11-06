using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.LessonEngine;

public sealed class StageDependencyConfiguration : IEntityTypeConfiguration<StageDependency>
{
    public void Configure(EntityTypeBuilder<StageDependency> builder)
    {
        ModelConventions.Configure(builder, "stage_dependencies");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.StageId).IsRequired();
        builder.Property(x => x.RequiredStageId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StageId, x.RequiredStageId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_stage_dependencies_1", "stage_id <> required_stage_id"));
        builder.HasOne<LanguagePlatform.Domain.LessonEngine.LessonStage>().WithMany().HasForeignKey(x => new { x.StageId, x.LessonVersionId }).HasPrincipalKey(x => new { x.Id, x.LessonVersionId }).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.LessonEngine.LessonStage>().WithMany().HasForeignKey(x => new { x.RequiredStageId, x.LessonVersionId }).HasPrincipalKey(x => new { x.Id, x.LessonVersionId }).OnDelete(DeleteBehavior.Restrict);

    }
}

