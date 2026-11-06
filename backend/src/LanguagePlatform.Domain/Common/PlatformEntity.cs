namespace LanguagePlatform.Domain.Common;

/// <summary>Identity shared by persisted module records; audit fields belong to individual models.</summary>
public abstract class PlatformEntity
{
    public Guid Id { get; init; } = Guid.NewGuid();
}
