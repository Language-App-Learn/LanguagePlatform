using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace LanguagePlatform.Api.IntegrationTests;

public sealed class CatalogApiTests(LanguagePlatformApiFactory factory)
    : IClassFixture<LanguagePlatformApiFactory>
{
    [Fact]
    public async Task HealthReturnsHealthy()
    {
        using var client = factory.CreateClient();

        using var response = await client.GetAsync("/health", CancellationToken.None);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", await response.Content.ReadAsStringAsync(CancellationToken.None));
    }

    [Theory]
    [InlineData("/api/v1/catalog/languages")]
    [InlineData("/api/v1/catalog/learning-paths")]
    [InlineData("/api/v1/catalog/programs")]
    [InlineData("/api/v1/catalog/courses")]
    public async Task CatalogEndpointsReturnValidJson(string endpoint)
    {
        using var client = factory.CreateClient();

        using var response = await client.GetAsync(endpoint, CancellationToken.None);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/json", response.Content.Headers.ContentType?.MediaType);
        var json = await response.Content.ReadFromJsonAsync<JsonElement>(CancellationToken.None);
        Assert.Equal(JsonValueKind.Array, json.ValueKind);
    }
}
