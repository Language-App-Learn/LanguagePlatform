using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Reading;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Reading;

public sealed class ReadingEvaluationConfiguration : IEntityTypeConfiguration<ReadingEvaluation>
{
    public void Configure(EntityTypeBuilder<ReadingEvaluation> builder)
    {
        ModelConventions.Configure(builder, "reading_evaluations");
        builder.Property(x => x.ReadingSessionId).IsRequired();
        builder.Property(x => x.AIEvaluationRequestId).IsRequired();
        builder.HasOne<LanguagePlatform.Domain.Reading.ReadingSession>().WithMany().HasForeignKey(x => x.ReadingSessionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.AITraining.AIEvaluationRequest>().WithMany().HasForeignKey(x => x.AIEvaluationRequestId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.AIEvaluationRequestId).IsUnique();

    }
}

