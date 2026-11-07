using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Platform;

public sealed class IdempotencyRecord : PlatformEntity
{
    public required Guid UserId { get; init; }
    public required string Scope { get; init; }
    public required string Key { get; init; }
    public required string RequestHash { get; init; }
    public int? ResponseCode { get; init; }
    public string? ResponseJson { get; init; }
    public required DateTime CreatedAtUtc { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public uint Version { get; private set; }
}
