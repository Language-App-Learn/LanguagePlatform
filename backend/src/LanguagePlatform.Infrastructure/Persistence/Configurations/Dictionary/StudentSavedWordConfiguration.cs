using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using LanguagePlatform.Domain.Dictionary;

namespace LanguagePlatform.Infrastructure.Persistence.Configurations.Dictionary;

public sealed class StudentSavedWordConfiguration : IEntityTypeConfiguration<StudentSavedWord>
{
    public void Configure(EntityTypeBuilder<StudentSavedWord> builder)
    {
        ModelConventions.Configure(builder, "student_saved_words");
        builder.Property(x => x.StudentId).IsRequired();
        builder.Property(x => x.DictionaryEntryId).IsRequired();
        builder.Property(x => x.SavedAtUtc).IsRequired();
        builder.Property(x => x.Note).HasMaxLength(2000);
        builder.Property(x => x.IsFavorite).HasDefaultValue(true);
        builder.HasOne<LanguagePlatform.Infrastructure.Identity.ApplicationUser>().WithMany().HasForeignKey(x => x.StudentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<LanguagePlatform.Domain.Dictionary.DictionaryEntry>().WithMany().HasForeignKey(x => x.DictionaryEntryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.StudentId, x.DictionaryEntryId }).IsUnique();

    }
}
