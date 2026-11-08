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
using LanguagePlatform.Infrastructure.Identity;
using LanguagePlatform.Infrastructure.StudentProgress;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.RateLimiting;
using Npgsql;

if (args is [IsolatedPdfTextExtractor.WorkerCommand])
{
    Environment.ExitCode = await PdfExtractionWorker.RunAsync();
    return;
}

var operatorMode = args is ["operator", ..];
var builder = WebApplication.CreateBuilder(operatorMode ? [] : args);
ProductionSecurity.Configure(builder);
SmtpAccountEmailDelivery.Configure(builder.Services, builder.Configuration);
if (builder.Environment.IsProduction())
    builder.WebHost.ConfigureKestrel(options => options.Limits.MaxRequestBodySize = 4 * 1024 * 1024);

builder.Services.AddSingleton(services =>
    new StudentReleaseOptions((builder.Environment.IsDevelopment() || builder.Environment.IsEnvironment("Testing"))
        && services.GetRequiredService<IConfiguration>().GetValue<bool>("StudentRelease:IncludeLegacyContent")));

builder.Services.AddDbContext<LanguagePlatformDbContext>((services, options) =>
    options.UseNpgsql(
        ProductionSecurity.DatabaseConnection(services.GetRequiredService<IConfiguration>(),
            services.GetRequiredService<IHostEnvironment>()),
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
builder.Services.AddScoped<CurriculumAuthoringService>();
builder.Services.AddScoped<CurriculumQueries>();
builder.Services.AddScoped<ReadingPdfService>();
builder.Services.AddScoped<OperatorAccessService>();
if (builder.Environment.IsProduction())
{
    var executable = Environment.ProcessPath ?? throw new InvalidOperationException("The PDF worker executable could not be resolved.");
    var entryPoint = Path.GetFileNameWithoutExtension(executable).Equals("dotnet", StringComparison.OrdinalIgnoreCase)
        ? typeof(Program).Assembly.Location : null;
    builder.Services.AddSingleton<IPdfTextExtractor>(new IsolatedPdfTextExtractor(executable, entryPoint));
}
else
{
    builder.Services.AddSingleton<IPdfTextExtractor, PdfTextExtractor>();
}
builder.Services.AddSingleton(services => new MediaHostPolicy(builder.Environment.IsProduction(),
    services.GetRequiredService<IConfiguration>().GetSection("Media:AllowedHosts").Get<string[]>() ?? []));
if (builder.Configuration.GetValue<bool>("PdfScanning:Enabled"))
{
    var scannerPort = builder.Configuration.GetValue("PdfScanning:Port", 3310);
    if (scannerPort is < 1 or > 65535) throw new InvalidOperationException("Configure a valid PDF scanner port.");
    builder.Services.AddSingleton<IPdfMalwareScanner>(new ClamAvPdfScanner(System.Net.IPAddress.Loopback, scannerPort));
}

builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = context =>
    context.ProblemDetails.Extensions["traceId"] = context.HttpContext.TraceIdentifier);
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddHealthChecks().AddCheck<PostgreSqlReadiness>("postgresql", tags: ["ready"]);
builder.Services.AddMobileAuthentication(builder.Environment.IsProduction());
builder.Services.AddRateLimiter(options => options.AddConcurrencyLimiter(ReadingPdfEndpoints.UploadRatePolicy,
    limiter =>
    {
        limiter.PermitLimit = 2;
        limiter.QueueLimit = 0;
    }));
builder.Services.AddOpenApi("v1", OpenApiAuthentication.Configure);

var app = builder.Build();
ProductionSecurity.VerifyHost(app);
if (operatorMode)
{
    Environment.ExitCode = await OperatorCommand.RunAsync(app, args, CancellationToken.None);
    await app.DisposeAsync();
    return;
}

app.UseExceptionHandler();
app.UseStatusCodePages();
if (app.Configuration.GetSection("ReverseProxy:KnownProxies").GetChildren().Any()) app.UseForwardedHeaders();
if (app.Environment.IsProduction())
{
    app.UseHsts();
    app.Use(async (context, next) =>
    {
        if (!context.Request.IsHttps)
        {
            await Results.Problem(statusCode: 400, title: "HTTPS is required.").ExecuteAsync(context);
            return;
        }
        await next(context);
    });
}
else if (!app.Environment.IsEnvironment("Testing"))
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
app.MapFiveStageEndpoints();
app.MapReadingPdfEndpoints();

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
