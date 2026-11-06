using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Assessment;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Assessment;

public sealed class ScoringRubricConfiguration : IEntityTypeConfiguration<ScoringRubric>
{
    public void Configure(EntityTypeBuilder<ScoringRubric> builder)
    {
        ModelConventions.Configure(builder, "scoring_rubrics");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.VersionNumber).IsRequired();
        builder.Property(x => x.CriteriaJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.MaximumScore).HasPrecision(18, 4).IsRequired();
        builder.HasIndex(x => new { x.Code, x.VersionNumber }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_scoring_rubrics_1", "version_number > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_scoring_rubrics_2", "maximum_score > 0"));

    }
}

