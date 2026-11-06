using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIProviderConfigurationConfiguration : IEntityTypeConfiguration<AIProviderConfiguration>
{
    public void Configure(EntityTypeBuilder<AIProviderConfiguration> builder)
    {
        ModelConventions.Configure(builder, "ai_provider_configurations");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Model).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Capability).HasMaxLength(64).IsRequired();
        builder.Property(x => x.SecretReference).HasMaxLength(256).IsRequired();
        builder.Property(x => x.IsEnabled).IsRequired();
        builder.HasIndex(x => new { x.Code, x.Model, x.Capability }).IsUnique();

    }
}

