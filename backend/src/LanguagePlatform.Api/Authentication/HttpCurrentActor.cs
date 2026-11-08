using System.Security.Claims;
using LanguagePlatform.Application.Identity;

namespace LanguagePlatform.Api.Authentication;

public sealed class HttpCurrentActor(IHttpContextAccessor accessor) : ICurrentActor
{
    public const string PermissionClaim = Permissions.ClaimType;
    private ClaimsPrincipal? Principal => accessor.HttpContext?.User;

    public Guid? UserId => Principal?.Identity?.IsAuthenticated == true
        && Guid.TryParse(Principal.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : null;

    public bool HasPermission(string permission) => UserId.HasValue && Principal!.HasClaim(PermissionClaim, permission);
}
