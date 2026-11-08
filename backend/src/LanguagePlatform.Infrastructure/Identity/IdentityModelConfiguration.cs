using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Identity;

internal static class IdentityModelConfiguration
{
    public static void Configure(ModelBuilder model)
    {
        model.Entity<ApplicationUser>().ToTable("identity_users");
        model.Entity<IdentityRole<Guid>>().ToTable("identity_roles");
        model.Entity<IdentityUserRole<Guid>>().ToTable("identity_user_roles");
        model.Entity<IdentityUserLogin<Guid>>().ToTable("identity_external_logins");
        model.Entity<IdentityUserClaim<Guid>>().ToTable("identity_user_claims");
        model.Entity<IdentityRoleClaim<Guid>>().ToTable("identity_role_claims");
        model.Entity<IdentityUserToken<Guid>>().ToTable("identity_user_tokens");
        model.Entity<ApplicationUser>().Property(x => x.Email).IsRequired();
        model.Entity<ApplicationUser>().Property(x => x.NormalizedEmail).IsRequired();
        model.Entity<ApplicationUser>().HasIndex(x => x.NormalizedEmail).IsUnique();

        foreach (var entity in model.Model.GetEntityTypes().Where(x =>
                     x.ClrType.Namespace?.StartsWith("Microsoft.AspNetCore.Identity", StringComparison.Ordinal) == true
                     || x.ClrType == typeof(ApplicationUser)))
        {
            foreach (var property in entity.GetProperties())
            {
                property.SetColumnName(Persistence.ModelConventions.SnakeCase(property.Name));
            }

            foreach (var key in entity.GetForeignKeys())
            {
                key.DeleteBehavior = DeleteBehavior.Restrict;
            }
        }
    }
}
