using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Identity;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Identity;

public sealed class UserConsentConfiguration : IEntityTypeConfiguration<UserConsent>
{
    public void Configure(EntityTypeBuilder<UserConsent> builder)
    {
        ModelConventions.Configure(builder, "user_consents");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.Purpose).HasMaxLength(80).IsRequired();
        builder.Property(x => x.PolicyVersion).HasMaxLength(32).IsRequired();
        builder.Property(x => x.GrantedAtUtc).IsRequired();
        builder.Property(x => x.WithdrawnAtUtc);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.UserId, x.Purpose, x.PolicyVersion }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_user_consents_1", "withdrawn_at_utc IS NULL OR withdrawn_at_utc >= granted_at_utc"));

    }
}
