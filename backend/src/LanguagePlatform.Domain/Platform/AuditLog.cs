using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Domain.Platform;

public sealed class AuditLog : PlatformEntity
{
    public Guid? ActorId { get; init; }
    public required string Action { get; init; }
    public required string EntityType { get; init; }
    public Guid? EntityId { get; init; }
    public required DateTime OccurredAtUtc { get; init; }
    public required string CorrelationId { get; init; }
    public required string RedactedChangesJson { get; init; }
}

