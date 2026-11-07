using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class AssessmentConfiguration : IEntityTypeConfiguration<LanguagePlatform.Domain.Assessment.Assessment>
{
    public void Configure(EntityTypeBuilder<LanguagePlatform.Domain.Assessment.Assessment> builder)
    {
        ModelConventions.Configure(builder, "assessments");
        builder.Property(x => x.LessonStageId).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.PassingScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.MaximumAttempts).IsRequired();
        builder.Property(x => x.TimeLimitSeconds);
        builder.Property(x => x.IsPublished).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.LessonEngine.LessonStage>().WithMany().HasForeignKey(x => x.LessonStageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.LessonStageId).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_assessments_1", "passing_score BETWEEN 0 AND 100"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessments_2", "maximum_attempts > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessments_3", "time_limit_seconds IS NULL OR time_limit_seconds > 0"));

    }
}
