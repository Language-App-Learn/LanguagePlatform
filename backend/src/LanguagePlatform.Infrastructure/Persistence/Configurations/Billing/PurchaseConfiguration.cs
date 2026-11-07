using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class PurchaseConfiguration : IEntityTypeConfiguration<Purchase>
{
    public void Configure(EntityTypeBuilder<Purchase> builder)
    {
        ModelConventions.Configure(builder, "purchases");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.PriceId).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalPurchaseId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Amount).HasPrecision(18, 4).IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.PurchasedAtUtc).IsRequired();
        builder.Property(x => x.VerifiedAtUtc);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Billing.Price>().WithMany().HasForeignKey(x => x.PriceId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Provider, x.ExternalPurchaseId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_purchases_1", "amount >= 0"));
        builder.ToTable(t => t.HasCheckConstraint("ck_purchases_2", "currency ~ '^[A-Z]{3}$'"));

    }
}
