namespace LanguagePlatform.Infrastructure.Persistence;

public static class CatalogSeedIds
{
    public static readonly Guid Turkish = Guid.Parse("10000000-0000-0000-0000-000000000001");
    public static readonly Guid Arabic = Guid.Parse("10000000-0000-0000-0000-000000000002");
    public static readonly Guid English = Guid.Parse("10000000-0000-0000-0000-000000000003");

    public static readonly Guid TurkishToArabic = Guid.Parse("20000000-0000-0000-0000-000000000001");
    public static readonly Guid EnglishToArabic = Guid.Parse("20000000-0000-0000-0000-000000000002");
    public static readonly Guid ArabicToTurkish = Guid.Parse("20000000-0000-0000-0000-000000000003");

    public static readonly Guid ModernLanguage = Guid.Parse("30000000-0000-0000-0000-000000000001");
    public static readonly Guid Ydt = Guid.Parse("30000000-0000-0000-0000-000000000002");
    public static readonly Guid Yds = Guid.Parse("30000000-0000-0000-0000-000000000003");
    public static readonly Guid Yokdil = Guid.Parse("30000000-0000-0000-0000-000000000004");
    public static readonly Guid QuranReading = Guid.Parse("30000000-0000-0000-0000-000000000005");
}
