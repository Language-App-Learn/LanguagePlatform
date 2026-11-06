using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Platform;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Platform;

public sealed class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> builder)
    {
        ModelConventions.Configure(builder, "audit_logs");
        builder.Property(x => x.ActorId);
        builder.Property(x => x.Action).HasMaxLength(100).IsRequired();
        builder.Property(x => x.EntityType).HasMaxLength(100).IsRequired();
        builder.Property(x => x.EntityId);
        builder.Property(x => x.OccurredAtUtc).IsRequired();
        builder.Property(x => x.CorrelationId).HasMaxLength(64).IsRequired();
        builder.Property(x => x.RedactedChangesJson).HasColumnType("jsonb").IsRequired();
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.ActorId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.EntityType, x.EntityId, x.OccurredAtUtc });
        builder.HasIndex(x => new { x.ActorId, x.OccurredAtUtc });

    }
}

