using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.Identity;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;

namespace LanguagePlatform.Application.StudentProgress;

public sealed record ProgressInput(Guid StudentId, LessonVersion Version,
    IReadOnlyList<LessonStage> Stages, IReadOnlyList<StageScore> Attempts);

public interface IProgressStore
{
    Task<ProgressInput?> ReadAsync(Guid lessonProgressId, CancellationToken cancellationToken);
    Task SaveAsync(Guid lessonProgressId, LessonScore result, CancellationToken cancellationToken);
}

public sealed class ProgressService(IProgressStore store, ICurrentActor actor)
{
    public async Task<LessonScore> RecalculateAsync(Guid progressId, CancellationToken cancellationToken)
    {
        var input = await store.ReadAsync(progressId, cancellationToken);
        if (input == null || (input.StudentId != actor.UserId && !actor.HasPermission(Permissions.StudentsManage)))
            throw new PermissionDeniedException();
        var score = LessonScoringPolicy.Evaluate(input.Version, input.Stages, input.Attempts);
        await store.SaveAsync(progressId, score, cancellationToken);
        return score;
    }
}
