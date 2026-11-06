using LanguagePlatform.Domain.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations;

public sealed class LearningProgramConfiguration : IEntityTypeConfiguration<LearningProgram>
{
    public void Configure(EntityTypeBuilder<LearningProgram> builder)
    {
        builder.ToTable("learning_programs");
        builder.HasKey(program => program.Id).HasName("pk_learning_programs");

        builder.Property(program => program.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(program => program.Code).HasColumnName("code").HasMaxLength(64).IsRequired();
        builder.Property(program => program.Name).HasColumnName("name").HasMaxLength(150).IsRequired();
        builder.Property(program => program.ProgramType)
            .HasColumnName("program_type")
            .HasConversion(type => type.Value, value => ProgramType.Create(value))
            .HasMaxLength(64)
            .IsRequired();
        builder.Property(program => program.IsActive).HasColumnName("is_active").IsRequired();

        builder.HasIndex(program => program.Code).IsUnique().HasDatabaseName("ux_learning_programs_code");
    }
}
