using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class PaymentTransactionConfiguration : IEntityTypeConfiguration<PaymentTransaction>
{
    public void Configure(EntityTypeBuilder<PaymentTransaction> builder)
    {
        ModelConventions.Configure(builder, "payment_transactions");
        builder.Property(x => x.PurchaseId).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalTransactionId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Amount).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.OccurredAtUtc).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Billing.Purchase>().WithMany().HasForeignKey(x => x.PurchaseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Provider, x.ExternalTransactionId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_payment_transactions_1", "amount >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_payment_transactions_2", "currency ~ '^[A-Z]{3}$'"));

    }
}
