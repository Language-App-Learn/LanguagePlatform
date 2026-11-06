using LanguagePlatform.Api.Endpoints;
using LanguagePlatform.Api.Authentication;
using LanguagePlatform.Api.ErrorHandling;
using LanguagePlatform.Api.Health;
using LanguagePlatform.Application.Catalog;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Infrastructure.Catalog;
using LanguagePlatform.Infrastructure.Assessment;
using LanguagePlatform.Infrastructure.CourseContent;
using LanguagePlatform.Infrastructure.Dictionary;
using LanguagePlatform.Infrastructure.Persistence;
using LanguagePlatform.Infrastructure.StudentProgress;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<LanguagePlatformDbContext>((services, options) =>
    options.UseNpgsql(
        services.GetRequiredService<IConfiguration>().GetConnectionString("LanguagePlatform")
            ?? "Host=localhost;Port=5432;Database=language_platform_dev;Username=postgres;Include Error Detail=false",
        npgsql => npgsql.MigrationsAssembly(typeof(LanguagePlatformDbContext).Assembly.FullName)
            .EnableRetryOnFailure()));

builder.Services.AddScoped<ILearningCatalogRepository, EfLearningCatalogRepository>();
builder.Services.AddScoped<ILearningCatalogService, LearningCatalogService>();
builder.Services.AddScoped<CatalogDataSeeder>();
builder.Services.AddScoped<DevelopmentContentSeeder>();
builder.Services.AddScoped<IPublishedContentQueries, PublishedContentQueries>();
builder.Services.AddScoped<StudentLearningService>();
builder.Services.AddScoped<ObjectiveAssessmentService>();
builder.Services.AddScoped<VocabularyService>();
builder.Services.AddScoped<ILessonPublicationStore, LessonPublicationStore>();
builder.Services.AddScoped<LessonPublicationService>();

builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = context =>
    context.ProblemDetails.Extensions["traceId"] = context.HttpContext.TraceIdentifier);
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddHealthChecks().AddCheck<PostgreSqlReadiness>("postgresql", tags: ["ready"]);
builder.Services.AddMobileAuthentication();
builder.Services.AddOpenApi("v1", OpenApiAuthentication.Configure);

var app = builder.Build();

app.UseExceptionHandler();
app.UseStatusCodePages();
if (!app.Environment.IsEnvironment("Testing"))
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi("/openapi/{documentName}.json");
}

app.MapHealthChecks("/health", new HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new HealthCheckOptions { Predicate = check => check.Tags.Contains("ready") });
app.MapCatalogEndpoints();
app.MapAccountEndpoints();
app.MapPublishedContentEndpoints();
app.MapStudentLearningEndpoints();
app.MapObjectiveAssessmentEndpoints();
app.MapVocabularyEndpoints();
app.MapAdminPublicationEndpoints();

await InitializeDatabaseWhenRequestedAsync(app);
await app.RunAsync();

static async Task InitializeDatabaseWhenRequestedAsync(WebApplication app)
{
    var applyMigrations = app.Configuration.GetValue<bool>("Database:ApplyMigrationsOnStartup");
    var seedData = app.Configuration.GetValue<bool>("Database:SeedOnStartup");
    var seedDemo = app.Configuration.GetValue<bool>("Database:SeedDemoContentOnStartup");

    if (!applyMigrations && !seedData && !seedDemo)
    {
        return;
    }

    if (!app.Environment.IsDevelopment())
    {
        throw new InvalidOperationException("Startup migrations and seed are restricted to Development.");
    }

    await using var scope = app.Services.CreateAsyncScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<LanguagePlatformDbContext>();
    var target = new NpgsqlConnectionStringBuilder(dbContext.Database.GetConnectionString());
    if (target.Database != "language_platform_dev" || target.Host is not ("localhost" or "127.0.0.1" or "::1"))
        throw new InvalidOperationException("Startup migrations and seed require a local language_platform_dev database.");

    if (applyMigrations)
    {
        await dbContext.Database.MigrateAsync();
    }

    if (seedDemo)
    {
        await scope.ServiceProvider.GetRequiredService<DevelopmentContentSeeder>().SeedAsync(CancellationToken.None);
    }
    else if (seedData)
    {
        var seeder = scope.ServiceProvider.GetRequiredService<CatalogDataSeeder>();
        await seeder.SeedAsync();
    }
}

public partial class Program;
