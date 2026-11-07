using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AITutorPromptVersionConfiguration : IEntityTypeConfiguration<AITutorPromptVersion>
{
    public void Configure(EntityTypeBuilder<AITutorPromptVersion> builder)
    {
        ModelConventions.Configure(builder, "ai_tutor_prompt_versions");
        builder.Property(x => x.AITutorId).IsRequired();
        builder.Property(x => x.VersionNumber).IsRequired();
        builder.Property(x => x.SystemPrompt).HasMaxLength(16000).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.PublishedAtUtc);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AITutor>().WithMany().HasForeignKey(x => x.AITutorId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.AITutorId, x.VersionNumber }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_tutor_prompt_versions_1", "version_number > 0"));

    }
}
