using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class SubscriptionPlanConfiguration : IEntityTypeConfiguration<SubscriptionPlan>
{
    public void Configure(EntityTypeBuilder<SubscriptionPlan> builder)
    {
        ModelConventions.Configure(builder, "subscription_plans");
        builder.Property(x => x.ProductId).IsRequired();
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.BillingPeriodMonths).IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Billing.Product>().WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.Code).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_subscription_plans_1", "billing_period_months >= 0"));

    }
}

