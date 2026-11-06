using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class LanguagePlatformDbContext(DbContextOptions<LanguagePlatformDbContext> options)
    : DbContext(options)
{
    public DbSet<Language> Languages => Set<Language>();
    public DbSet<LearningPath> LearningPaths => Set<LearningPath>();
    public DbSet<LearningProgram> LearningPrograms => Set<LearningProgram>();
    public DbSet<Course> Courses => Set<Course>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(LanguagePlatformDbContext).Assembly);
    }
}
