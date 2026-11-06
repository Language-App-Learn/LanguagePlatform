using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class PlanEntitlementConfiguration : IEntityTypeConfiguration<PlanEntitlement>
{
    public void Configure(EntityTypeBuilder<PlanEntitlement> builder)
    {
        ModelConventions.Configure(builder, "plan_entitlements");
        builder.Property(x => x.SubscriptionPlanId).IsRequired();
        builder.Property(x => x.EntitlementId).IsRequired();
        builder.Property(x => x.UsageLimit);
        builder.HasOne<LanguagePlatform.Domain.Billing.SubscriptionPlan>().WithMany().HasForeignKey(x => x.SubscriptionPlanId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Billing.Entitlement>().WithMany().HasForeignKey(x => x.EntitlementId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.SubscriptionPlanId, x.EntitlementId }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_plan_entitlements_1", "usage_limit IS NULL OR usage_limit > 0"));

    }
}

