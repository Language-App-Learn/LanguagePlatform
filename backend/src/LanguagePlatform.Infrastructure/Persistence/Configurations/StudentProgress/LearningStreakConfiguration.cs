using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.StudentProgress;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.StudentProgress;

public sealed class LearningStreakConfiguration : IEntityTypeConfiguration<LearningStreak>
{
    public void Configure(EntityTypeBuilder<LearningStreak> builder)
    {
        ModelConventions.Configure(builder, "learning_streaks");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.ActivityDate).IsRequired();
        builder.Property(x => x.ActiveMinutes).IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.ActivityDate }).IsUnique();
        builder.ToTable(t => t.HasCheckConstraint("ck_learning_streaks_1", "active_minutes > 0"));

    }
}

