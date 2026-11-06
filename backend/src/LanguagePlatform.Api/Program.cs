using LanguagePlatform.Api.Endpoints;
using LanguagePlatform.Api.ErrorHandling;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("LanguagePlatform")
    ?? "Host=localhost;Port=5432;Database=language_platform_dev;Username=postgres;Include Error Detail=false";

builder.Services.AddDbContext<LanguagePlatformDbContext>(options =>
    options.UseNpgsql(
        connectionString,
        npgsql => npgsql.MigrationsAssembly(typeof(LanguagePlatformDbContext).Assembly.FullName)
            .EnableRetryOnFailure()));

builder.Services.AddScoped<ILearningCatalogRepository, EfLearningCatalogRepository>();
builder.Services.AddScoped<ILearningCatalogService, LearningCatalogService>();
builder.Services.AddScoped<CatalogDataSeeder>();

builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddHealthChecks();
builder.Services.AddAuthorization();
builder.Services.AddOpenApi("v1");

var app = builder.Build();

app.UseExceptionHandler();
if (!app.Environment.IsEnvironment("Testing"))
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi("/openapi/{documentName}.json");
}

app.MapHealthChecks("/health");
app.MapCatalogEndpoints();

await InitializeDatabaseWhenRequestedAsync(app);
await app.RunAsync();

static async Task InitializeDatabaseWhenRequestedAsync(WebApplication app)
{
    var applyMigrations = app.Configuration.GetValue<bool>("Database:ApplyMigrationsOnStartup");
    var seedData = app.Configuration.GetValue<bool>("Database:SeedOnStartup");

    if (!applyMigrations && !seedData)
    {
        return;
    }

    if (app.Environment.IsProduction() && applyMigrations)
    {
        throw new InvalidOperationException("Automatic database migrations are disabled in production.");
    }

    await using var scope = app.Services.CreateAsyncScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<LanguagePlatformDbContext>();

    if (applyMigrations)
    {
        await dbContext.Database.MigrateAsync();
    }

    if (seedData)
    {
        var seeder = scope.ServiceProvider.GetRequiredService<CatalogDataSeeder>();
        await seeder.SeedAsync();
    }
}

public partial class Program;
