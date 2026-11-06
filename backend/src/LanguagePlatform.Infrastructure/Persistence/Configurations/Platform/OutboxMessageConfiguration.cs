using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Platform;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Platform;

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        ModelConventions.Configure(builder, "outbox_messages");
        builder.Property(x => x.EventType).HasMaxLength(160).IsRequired();
        builder.Property(x => x.SchemaVersion).IsRequired();
        builder.Property(x => x.PayloadJson).HasColumnType("jsonb").IsRequired();
        builder.Property(x => x.OccurredAtUtc).IsRequired();
        builder.Property(x => x.AvailableAtUtc).IsRequired();
        builder.Property(x => x.LeaseUntilUtc);
        builder.Property(x => x.ProcessedAtUtc);
        builder.Property(x => x.AttemptCount).IsRequired();
        builder.Property(x => x.ErrorCode).HasMaxLength(80);
        builder.Property(x => x.CorrelationId).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.ToTable(t => t.HasCheckConstraint("ck_outbox_messages_1", "schema_version > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_outbox_messages_2", "attempt_count >= 0"));
        builder.HasIndex(x => x.AvailableAtUtc).HasFilter("processed_at_utc IS NULL");

    }
}

