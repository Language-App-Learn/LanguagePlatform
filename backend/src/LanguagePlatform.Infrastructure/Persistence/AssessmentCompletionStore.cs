using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Domain.Assessment;
using Microsoft.EntityFrameworkCore;

namespace LanguagePlatform.Infrastructure.Persistence;

public sealed class AssessmentCompletionStore(LanguagePlatformDbContext db) : IAssessmentCompletionStore
{
    public Task<AssessmentAttempt?> FindAsync(Guid id, CancellationToken cancellationToken) =>
        db.Set<AssessmentAttempt>().SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<decimal?> GetFullyEvaluatedScoreAsync(Guid attemptId, CancellationToken cancellationToken)
    {
        var scores = await (
            from snapshot in db.Set<AssessmentAttemptQuestion>()
            where snapshot.AssessmentAttemptId == attemptId
            join answer in db.Set<StudentAnswer>() on snapshot.Id equals answer.AttemptQuestionId into answers
            from answer in answers.DefaultIfEmpty()
            join evaluation in db.Set<AnswerEvaluation>() on answer.Id equals evaluation.StudentAnswerId into evaluations
            from evaluation in evaluations.DefaultIfEmpty()
            select new { Score = (decimal?)evaluation.Score, snapshot.MaximumScore })
            .ToListAsync(cancellationToken);
        if (scores.Count == 0 || scores.Any(x => x.Score == null || x.Score > x.MaximumScore)) return null;
        return scores.Sum(x => x.Score!.Value);
    }

    public async Task SaveAsync(CancellationToken cancellationToken) => await db.SaveChangesAsync(cancellationToken);
}
