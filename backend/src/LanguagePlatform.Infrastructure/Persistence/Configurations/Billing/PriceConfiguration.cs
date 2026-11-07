using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class PriceConfiguration : IEntityTypeConfiguration<Price>
{
    public void Configure(EntityTypeBuilder<Price> builder)
    {
        ModelConventions.Configure(builder, "billing_prices");
        builder.Property(x => x.ProductId).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalPriceId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Amount).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.ValidFromUtc).IsRequired();
        builder.Property(x => x.ValidUntilUtc);
        builder.HasOne<LanguagePlatform.Domain.Billing.Product>().WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Provider, x.ExternalPriceId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_billing_prices_1", "amount >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_billing_prices_2", "currency ~ '^[A-Z]{3}$'"));
        builder.ToTable(t => t.HasCheckConstraint("ck_billing_prices_3", "valid_until_utc IS NULL OR valid_until_utc > valid_from_utc"));

    }
}
