using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class EntitlementGrantConfiguration : IEntityTypeConfiguration<EntitlementGrant>
{
    public void Configure(EntityTypeBuilder<EntitlementGrant> builder)
    {
        ModelConventions.Configure(builder, "entitlement_grants");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.EntitlementId).IsRequired();
        builder.Property(x => x.PurchaseId);
        builder.Property(x => x.GrantedBy);
        builder.Property(x => x.StartsAtUtc).IsRequired();
        builder.Property(x => x.EndsAtUtc);
        builder.Property(x => x.RevokedAtUtc);
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Billing.Entitlement>().WithMany().HasForeignKey(x => x.EntitlementId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Billing.Purchase>().WithMany().HasForeignKey(x => x.PurchaseId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.GrantedBy).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.UserId, x.IdempotencyKey }).IsUnique();
        builder.HasIndex(x => new { x.UserId, x.EntitlementId });
        builder.ToTable(t => t.HasCheckConstraint("ck_entitlement_grants_1", "purchase_id IS NOT NULL OR granted_by IS NOT NULL"));
        builder.ToTable(t => t.HasCheckConstraint("ck_entitlement_grants_2", "ends_at_utc IS NULL OR ends_at_utc > starts_at_utc"));

    }
}

