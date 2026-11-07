using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class MorphologicalAnalysisConfiguration : IEntityTypeConfiguration<MorphologicalAnalysis>
{
    public void Configure(EntityTypeBuilder<MorphologicalAnalysis> builder)
    {
        ModelConventions.Configure(builder, "morphological_analyses");
        builder.Property(x => x.WordFormId).IsRequired();
        builder.Property(x => x.AnalyzerVersion).HasMaxLength(64).IsRequired();
        builder.Property(x => x.FeaturesSchemaVersion).IsRequired();
        builder.Property(x => x.FeaturesJson).HasColumnType("jsonb").IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Dictionary.WordForm>().WithMany().HasForeignKey(x => x.WordFormId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.WordFormId, x.AnalyzerVersion }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_morphological_analyses_1", "features_schema_version > 0"));

    }
}
