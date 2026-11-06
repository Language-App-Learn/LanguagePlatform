using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AISessionConfiguration : IEntityTypeConfiguration<AISession>
{
    public void Configure(EntityTypeBuilder<AISession> builder)
    {
        ModelConventions.Configure(builder, "ai_sessions");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.PromptVersionId).IsRequired();
        builder.Property(x => x.ProviderConfigurationId).IsRequired();
        builder.Property(x => x.StartedAtUtc).IsRequired();
        builder.Property(x => x.EndedAtUtc);
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AITutorPromptVersion>().WithMany().HasForeignKey(x => x.PromptVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIProviderConfiguration>().WithMany().HasForeignKey(x => x.ProviderConfigurationId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.StartedAtUtc });
        builder.HasIndex(x => x.ExpiresAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_sessions_1", "expires_at_utc > started_at_utc"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_sessions_2", "ended_at_utc IS NULL OR ended_at_utc >= started_at_utc"));

    }
}

