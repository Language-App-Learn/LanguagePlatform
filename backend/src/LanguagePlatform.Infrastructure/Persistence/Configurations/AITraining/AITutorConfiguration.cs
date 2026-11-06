using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.AITraining;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.AITraining;

public sealed class AITutorConfiguration : IEntityTypeConfiguration<AITutor>
{
    public void Configure(EntityTypeBuilder<AITutor> builder)
    {
        ModelConventions.Configure(builder, "ai_tutors");
        builder.Property(x => x.Code).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.LanguageId).IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Catalog.Language>().WithMany().HasForeignKey(x => x.LanguageId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.Code).IsUnique();

    }
}

