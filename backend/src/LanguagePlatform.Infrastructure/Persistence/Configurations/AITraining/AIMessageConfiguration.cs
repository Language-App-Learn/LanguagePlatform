using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AIMessageConfiguration : IEntityTypeConfiguration<AIMessage>
{
    public void Configure(EntityTypeBuilder<AIMessage> builder)
    {
        ModelConventions.Configure(builder, "ai_messages");
        builder.Property(x => x.AISessionId).IsRequired();
        builder.Property(x => x.Sequence).IsRequired();
        builder.Property(x => x.Speaker).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Text).HasMaxLength(16000);
        builder.Property(x => x.AudioAssetId);
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.AITraining.AISession>().WithMany().HasForeignKey(x => x.AISessionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.MediaManagement.MediaAsset>().WithMany().HasForeignKey(x => x.AudioAssetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.AISessionId, x.Sequence }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_messages_1", "sequence > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_messages_2", "text IS NOT NULL OR audio_asset_id IS NOT NULL"));
        builder.ToTable(t => t.HasCheckConstraint("ck_ai_messages_3", "speaker IN ('Student','Tutor','System')"));

    }
}
