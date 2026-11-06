using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class LanguagePlatformDbContext(DbContextOptions<LanguagePlatformDbContext> options)
    : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<Language> Languages => Set<Language>();
    public DbSet<LearningPath> LearningPaths => Set<LearningPath>();
    public DbSet<LearningProgram> LearningPrograms => Set<LearningProgram>();
    public DbSet<Course> Courses => Set<Course>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        IdentityModelConfiguration.Configure(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(LanguagePlatformDbContext).Assembly);
    }
}
