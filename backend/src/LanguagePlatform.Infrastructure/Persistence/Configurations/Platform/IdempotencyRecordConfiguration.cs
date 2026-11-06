using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Platform;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Platform;

public sealed class IdempotencyRecordConfiguration : IEntityTypeConfiguration<IdempotencyRecord>
{
    public void Configure(EntityTypeBuilder<IdempotencyRecord> builder)
    {
        ModelConventions.Configure(builder, "idempotency_records");
        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.Scope).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Key).HasMaxLength(128).IsRequired();
        builder.Property(x => x.RequestHash).HasMaxLength(128).IsRequired();
        builder.Property(x => x.ResponseCode);
        builder.Property(x => x.ResponseJson).HasColumnType("jsonb");
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.ExpiresAtUtc).IsRequired();
        builder.Property(x => x.Version).IsRowVersion().HasColumnName("xmin");
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.UserId, x.Scope, x.Key }).IsUnique();
        builder.HasIndex(x => x.ExpiresAtUtc);
        builder.ToTable(t => t.HasCheckConstraint("ck_idempotency_records_1", "expires_at_utc > created_at_utc"));
        builder.ToTable(t => t.HasCheckConstraint("ck_idempotency_records_2", "response_code IS NULL OR response_code BETWEEN 100 AND 599"));

    }
}

