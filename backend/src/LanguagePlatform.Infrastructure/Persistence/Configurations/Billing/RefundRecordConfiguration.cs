using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class RefundRecordConfiguration : IEntityTypeConfiguration<RefundRecord>
{
    public void Configure(EntityTypeBuilder<RefundRecord> builder)
    {
        ModelConventions.Configure(builder, "refund_records");
        builder.Property(x => x.PaymentTransactionId).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalRefundId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Amount).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.Reason).HasMaxLength(500).IsRequired();
        builder.Property(x => x.RefundedAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Billing.PaymentTransaction>().WithMany().HasForeignKey(x => x.PaymentTransactionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Provider, x.ExternalRefundId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_refund_records_1", "amount > 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_refund_records_2", "currency ~ '^[A-Z]{3}$'"));

    }
}

