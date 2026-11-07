using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class PaymentProviderEventConfiguration : IEntityTypeConfiguration<PaymentProviderEvent>
{
    public void Configure(EntityTypeBuilder<PaymentProviderEvent> builder)
    {
        ModelConventions.Configure(builder, "payment_provider_events");
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalEventId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.EventType).HasMaxLength(64).IsRequired();
        builder.Property(x => x.PayloadHash).HasMaxLength(128).IsRequired();
        builder.Property(x => x.ReceivedAtUtc).IsRequired();
        builder.Property(x => x.VerifiedAtUtc);
        builder.Property(x => x.ProcessedAtUtc);
        builder.Property(x => x.AttemptCount).IsRequired();
        builder.Property(x => x.ErrorCode).HasMaxLength(80);
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasIndex(x => new { x.Provider, x.ExternalEventId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_payment_provider_events_1", "attempt_count >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_payment_provider_events_2", "processed_at_utc IS NULL OR verified_at_utc IS NOT NULL"));

    }
}
