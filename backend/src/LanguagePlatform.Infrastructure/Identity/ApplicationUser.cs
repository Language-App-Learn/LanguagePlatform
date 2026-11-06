using Microsoft.AspNetCore.Identity;

namespace LanguagePlatform.Infrastructure.Identity;

// Framework identity remains outside Domain. Domain modules reference users by UUID.
public sealed class ApplicationUser : IdentityUser<Guid>
{
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? LastLoginAtUtc { get; set; }
}
