using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIUsageRecordConfiguration : IEntityTypeConfiguration<AIUsageRecord>
{
    public void Configure(EntityTypeBuilder<AIUsageRecord> builder)
    {
        ModelConventions.Configure(builder, "ai_usage_records");
        builder.Property(x => x.ProviderConfigurationId).IsRequired();
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.AISessionId);
        builder.Property(x => x.EvaluationRequestId);
        builder.Property(x => x.ProviderRequestId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.InputUnits).IsRequired();
        builder.Property(x => x.OutputUnits).IsRequired();
        builder.Property(x => x.Cost).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.RecordedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIProviderConfiguration>().WithMany().HasForeignKey(x => x.ProviderConfigurationId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AISession>().WithMany().HasForeignKey(x => x.AISessionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIEvaluationRequest>().WithMany().HasForeignKey(x => x.EvaluationRequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.ProviderConfigurationId, x.ProviderRequestId }).IsUnique();
        builder.HasIndex(x => x.RecordedAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_usage_records_1", "input_units >= 0 AND output_units >= 0 AND cost >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_usage_records_2", "currency ~ '^[A-Z]{3}$'"));

    }
}
