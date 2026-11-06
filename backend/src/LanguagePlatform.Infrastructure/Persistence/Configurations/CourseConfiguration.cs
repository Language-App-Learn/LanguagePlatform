using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations;

public sealed class CourseConfiguration : IEntityTypeConfiguration<Course>
{
    public void Configure(EntityTypeBuilder<Course> builder)
    {
        builder.ToTable("courses");
        builder.HasKey(course => course.Id).HasName("pk_courses");

        builder.Property(course => course.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(course => course.LearningPathId).HasColumnName("learning_path_id").IsRequired();
        builder.Property(course => course.LearningProgramId).HasColumnName("learning_program_id").IsRequired();
        builder.Property(course => course.Slug).HasColumnName("slug").HasMaxLength(120).IsRequired();
        builder.Property(course => course.Title).HasColumnName("title").HasMaxLength(200).IsRequired();
        builder.Property(course => course.Description).HasColumnName("description").HasMaxLength(2_000);
        builder.Property(course => course.Status).HasColumnName("status").HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.Property(course => course.UsesFiveStageCurriculum).HasColumnName("uses_five_stage_curriculum");

        builder.HasIndex(course => course.Slug).IsUnique().HasDatabaseName("ux_courses_slug");
        builder.HasIndex(course => course.LearningPathId).HasDatabaseName("ix_courses_learning_path_id");
        builder.HasIndex(course => course.LearningProgramId).HasDatabaseName("ix_courses_learning_program_id");

        builder.HasOne(course => course.LearningPath)
            .WithMany()
            .HasForeignKey(course => course.LearningPathId)
            .OnDelete(DeleteBehavior.Restrict)
            .HasConstraintName("fk_courses_learning_path");
        builder.HasOne(course => course.LearningProgram)
            .WithMany()
            .HasForeignKey(course => course.LearningProgramId)
            .OnDelete(DeleteBehavior.Restrict)
            .HasConstraintName("fk_courses_learning_program");
    }
}
