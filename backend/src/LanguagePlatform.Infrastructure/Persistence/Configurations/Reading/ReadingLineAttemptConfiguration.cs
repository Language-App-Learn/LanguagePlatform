using LanguagePlatform.Domain.Reading;
using LanguagePlatform.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingLineAttemptConfiguration : IEntityTypeConfiguration<ReadingLineAttempt>
{
    internal const string ActiveLineIndex = "ux_reading_line_attempts_active_line";
    internal const string IdempotencyIndex = "ux_reading_line_attempts_idempotency";

    public void Configure(EntityTypeBuilder<ReadingLineAttempt> builder)
    {
        ModelConventions.Configure(builder, "reading_line_attempts");
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        builder.Property(x => x.Reason).HasMaxLength(32);
        builder.HasOne<ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<ReadingTextSegment>().WithMany().HasForeignKey(x => x.SegmentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.IdempotencyKey }).IsUnique().HasDatabaseName(IdempotencyIndex);
        builder.HasIndex(x => new { x.StudentId, x.SegmentId }).IsUnique().HasDatabaseName(ActiveLineIndex)
            .HasFilter("status IN ('Pending', 'Approved')");
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_reading_line_attempts_digest", "octet_length(recording_digest) = 32");
            t.HasCheckConstraint("ck_reading_line_attempts_deadline", "deadline_utc > created_at_utc");
            t.HasCheckConstraint("ck_reading_line_attempts_status",
                "(status IN ('Pending', 'Approved') AND reason IS NULL) OR " +
                "(status IN ('RetryRequired', 'Inconclusive', 'TechnicalError') AND reason IS NOT NULL)");
        });
    }
}
