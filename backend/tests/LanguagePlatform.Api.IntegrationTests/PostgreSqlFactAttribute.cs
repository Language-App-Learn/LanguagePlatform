namespace LanguagePlatform.Api.IntegrationTests;

[AttributeUsage(AttributeTargets.Method)]
public sealed class PostgreSqlFactAttribute : FactAttribute
{
    public const string ConnectionVariable = "LANGUAGEPLATFORM_TEST_CONNECTION";

    public PostgreSqlFactAttribute()
    {
        if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(ConnectionVariable)))
        {
            Skip = $"Set {ConnectionVariable} to a dedicated PostgreSQL test database connection string.";
        }
    }
}
