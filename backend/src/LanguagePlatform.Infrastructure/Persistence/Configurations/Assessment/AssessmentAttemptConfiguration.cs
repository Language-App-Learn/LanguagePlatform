using Microsoft.EntityFrameworkCore;
using LanguagePlatform.Domain.Common;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class AssessmentAttemptConfiguration : IEntityTypeConfiguration<AssessmentAttempt>
{
    public void Configure(EntityTypeBuilder<AssessmentAttempt> builder)
    {
        ModelConventions.Configure(builder, "assessment_attempts");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.AssessmentId).IsRequired();
        builder.Property(x => x.StartedAtUtc).IsRequired();
        builder.Property(x => x.CompletedAtUtc);
        builder.Property(x => x.Score).HasPrecision(18, 4);
        builder.Property(x => x.MaximumScore).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
        builder.Property(x => x.AttemptNumber).IsRequired();
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Assessment.Assessment>().WithMany().HasForeignKey(x => x.AssessmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.AssessmentId, x.AttemptNumber }).IsUnique();
        builder.HasIndex(x => new { x.StudentId, x.IdempotencyKey }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_attempts_1", "attempt_number > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_attempts_2", "maximum_score > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_attempts_3", "score IS NULL OR (score >= 0 AND score <= maximum_score)"));
        builder.ToTable(t => t.HasCheckConstraint("ck_assessment_attempts_4", "completed_at_utc IS NULL OR completed_at_utc >= started_at_utc"));

    }
}

