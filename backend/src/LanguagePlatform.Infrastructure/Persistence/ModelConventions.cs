using System.Text.RegularExpressions;
using LanguagePlatform.Domain.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguagePlatform.Infrastructure.Persistence;

internal static partial class ModelConventions
{
    public static void Configure<T>(EntityTypeBuilder<T> builder, string table) where T : PlatformEntity
    {
        builder.ToTable(table);
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();
        foreach (var property in builder.Metadata.GetProperties())
        {
            property.SetColumnName(SnakeCase(property.Name));
        }
    }

    public static string SnakeCase(string name) =>
        WordBoundary().Replace(AcronymBoundary().Replace(name, "$1_$2"), "$1_$2").ToLowerInvariant();

    [GeneratedRegex("([a-z0-9])([A-Z])", RegexOptions.CultureInvariant)]
    private static partial Regex WordBoundary();

    [GeneratedRegex("([A-Z]+)([A-Z][a-z])", RegexOptions.CultureInvariant)]
    private static partial Regex AcronymBoundary();
}
