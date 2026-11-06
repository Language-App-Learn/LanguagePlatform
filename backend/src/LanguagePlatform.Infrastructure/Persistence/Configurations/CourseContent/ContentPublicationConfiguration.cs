using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.CourseContent;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.CourseContent;

public sealed class ContentPublicationConfiguration : IEntityTypeConfiguration<ContentPublication>
{
    public void Configure(EntityTypeBuilder<ContentPublication> builder)
    {
        ModelConventions.Configure(builder, "content_publications");
        builder.Property(x => x.LessonVersionId).IsRequired();
        builder.Property(x => x.PublishedBy).IsRequired();
        builder.Property(x => x.PublishedAtUtc).IsRequired();
        builder.Property(x => x.WithdrawnAtUtc);
        builder.Property(x => x.Reason).HasMaxLength(2000);
        builder.HasOne<LanguagePlatform.Domain.CourseContent.LessonVersion>().WithMany().HasForeignKey(x => x.LessonVersionId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.PublishedBy).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.LessonVersionId).IsUnique();

    }
}

