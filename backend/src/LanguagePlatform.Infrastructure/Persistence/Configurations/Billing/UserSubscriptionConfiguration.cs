using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Billing;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Billing;

public sealed class UserSubscriptionConfiguration : IEntityTypeConfiguration<UserSubscription>
{
    public void Configure(EntityTypeBuilder<UserSubscription> builder)
    {
        ModelConventions.Configure(builder, "user_subscriptions");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.SubscriptionPlanId).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ExternalSubscriptionId).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();
        builder.Property(x => x.StartsAtUtc).IsRequired();
        builder.Property(x => x.EndsAtUtc).IsRequired();
        builder.Property(x => x.CancelledAtUtc);
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Billing.SubscriptionPlan>().WithMany().HasForeignKey(x => x.SubscriptionPlanId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.Provider, x.ExternalSubscriptionId }).IsUnique();
        builder.HasIndex(x => new { x.UserId, x.Status });
        builder.ToTable(t => t.HasCheckConstraint("ck_user_subscriptions_1", "ends_at_utc > starts_at_utc"));
        builder.ToTable(t => t.HasCheckConstraint("ck_user_subscriptions_2", "status IN ('Active','Pending','Expired','Cancelled','GracePeriod','Refunded')"));

    }
}
