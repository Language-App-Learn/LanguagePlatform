using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class AssessmentResultConfiguration : IEntityTypeConfiguration<AssessmentResult>
{
    public void Configure(EntityTypeBuilder<AssessmentResult> builder)
    {
        ModelConventions.Configure(builder, "assessment_results");
        builder.Property(x => x.AssessmentAttemptId).IsRequired();
        builder.Property(x => x.StageAttemptId).IsRequired();
        builder.Property(x => x.RecordedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Assessment.AssessmentAttempt>().WithMany().HasForeignKey(x => x.AssessmentAttemptId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.StudentProgress.StageAttempt>().WithMany().HasForeignKey(x => x.StageAttemptId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.AssessmentAttemptId).IsUnique();
        builder.HasIndex(x => x.StageAttemptId).IsUnique();

    }
}
