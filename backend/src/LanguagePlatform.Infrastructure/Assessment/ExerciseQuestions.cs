using System.Text.Json;
using LanguagePlatform.Application.Assessment;
using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Common;

namespace LanguagePlatform.Infrastructure.Assessment;

internal static class ExerciseQuestions
{
    private const string Choice = "MultipleChoice";
    private const string Boolean = "TrueFalse";
    private const string WordBank = "WordBank";
    private const string FillBlank = "FillBlank";
    private const string WordOrder = "WordOrder";
    private const string ExactText = "ExactText";
    private const string Blank = "{{blank}}";

    internal static bool Supports(string stage, string kind) => stage switch
    {
        "reading" => kind is Choice or Boolean,
        "listening" => kind is WordBank or FillBlank,
        "writing" => kind is FillBlank or WordOrder,
        "translation" => kind is Choice or ExactText,
        _ => false
    };

    internal static string CreateKey(DraftQuestion input)
    {
        Guard.Against(input.MaximumScore is <= 0 or > 100
            || decimal.Round(input.MaximumScore, 4) != input.MaximumScore, "Question points must be positive and at most 100.");
        Guard.Against(input.Kind is WordBank or FillBlank && !HasOneBlank(input.Prompt),
            "Provide exactly one {{blank}} in a blank exercise prompt.");

        if (input.Kind == Boolean)
        {
            Guard.Against(input.CorrectValue is null || input.Options is not null ||
                input.AcceptedAnswers is not null || input.CorrectOrder is not null, "True/false requires a boolean answer key.");
            return JsonSerializer.Serialize(new { correctAnswer = input.CorrectValue });
        }
        if (input.Kind is FillBlank or ExactText)
        {
            Guard.Against(input.CorrectValue is not null || input.Options is not null ||
                input.CorrectOrder is not null || !ValidTextKeys(input.AcceptedAnswers), "Provide 1 to 20 distinct exact answers.");
            return JsonSerializer.Serialize(new Key(null, null, input.AcceptedAnswers!.ToArray()));
        }

        Guard.Against(input.CorrectValue is not null || input.AcceptedAnswers is not null ||
            input.Options is not { Count: >= 2 and <= 12 }, "Provide two to twelve display options.");
        var options = input.Options!;
        Guard.Against(options.Any(x => x is null || string.IsNullOrWhiteSpace(x.Text) || x.Text.Length > 4000
            || x.Text.Contains('\0')), "Each option needs valid text.");
        if (input.Kind == WordOrder)
        {
            Guard.Against(options.Any(x => x.IsCorrect) || !IsPermutation(input.CorrectOrder, options.Count),
                "Word ordering requires a permutation of the zero-based option positions.");
            return JsonSerializer.Serialize(new { correctOrder = input.CorrectOrder });
        }

        Guard.Against(input.Kind is not (Choice or WordBank) || input.CorrectOrder is not null ||
            options.Count(x => x.IsCorrect) != 1 ||
            options.Select(x => x.Text.Trim()).Distinct(StringComparer.Ordinal).Count() != options.Count,
            "Provide unique options and exactly one correct option.");
        return "{}";
    }

    internal static AssessmentAttemptQuestion Snapshot(Guid attemptId, AssessmentQuestion link, Question question,
        IReadOnlyList<QuestionOption> options)
    {
        var key = ReadKey(question, options);
        var publicOptions = options.Select(x => new ObjectiveOptionDto(x.Id, x.Text)).ToArray();
        return new AssessmentAttemptQuestion
        {
            AssessmentAttemptId = attemptId, QuestionId = question.Id, DisplayOrder = link.DisplayOrder,
            PromptSnapshot = question.Prompt, MaximumScore = link.MaximumScore,
            AnswerKeySnapshotJson = JsonSerializer.Serialize(key),
            OptionsSnapshotJson = JsonSerializer.Serialize(new Presentation(question.QuestionType, publicOptions))
        };
    }

    internal static void ValidateStored(Question question, IReadOnlyList<QuestionOption> options) => ReadKey(question, options);

    private static Key ReadKey(Question question, IReadOnlyList<QuestionOption> options)
    {
        if (question.IsArchived || string.IsNullOrWhiteSpace(question.Prompt) ||
            (question.QuestionType is WordBank or FillBlank && !HasOneBlank(question.Prompt)))
            throw InvalidQuestion();
        if (question.QuestionType is Choice or WordBank && options.Count >= 2 && options.Count(x => x.IsCorrect) == 1)
            return new Key(options.Single(x => x.IsCorrect).Id, null);

        using var json = JsonDocument.Parse(question.AnswerKeyJson);
        if (json.RootElement.ValueKind != JsonValueKind.Object) throw InvalidQuestion();
        if (question.QuestionType == Boolean && options.Count == 0 &&
            json.RootElement.TryGetProperty("correctAnswer", out var correct)
            && correct.ValueKind is JsonValueKind.True or JsonValueKind.False)
            return new Key(null, correct.GetBoolean());
        if (question.QuestionType is FillBlank or ExactText && options.Count == 0 &&
            json.RootElement.TryGetProperty(nameof(Key.AcceptedAnswers), out var accepted)
            && accepted.ValueKind == JsonValueKind.Array)
        {
            var answers = accepted.EnumerateArray().Select(x => x.ValueKind == JsonValueKind.String ? x.GetString() : null).ToArray();
            if (ValidTextKeys(answers)) return new Key(null, null, answers!);
        }
        if (question.QuestionType == WordOrder && options.Count >= 2 &&
            json.RootElement.TryGetProperty("correctOrder", out var order) && order.ValueKind == JsonValueKind.Array)
        {
            var indices = order.EnumerateArray().Select(x => x.ValueKind == JsonValueKind.Number && x.TryGetInt32(out var index)
                ? index : -1).ToArray();
            if (IsPermutation(indices, options.Count)) return new Key(null, null, null, indices.Select(x => options[x].Id).ToArray());
        }
        throw InvalidQuestion();
    }

    internal static decimal Grade(AssessmentAttemptQuestion snapshot, ObjectiveAnswer answer)
    {
        var question = ReadPresentation(snapshot);
        var key = JsonSerializer.Deserialize<Key>(snapshot.AnswerKeySnapshotJson)!;
        var fields = (answer.OptionId.HasValue ? 1 : 0) + (answer.Value.HasValue ? 1 : 0)
            + (answer.Text is null ? 0 : 1) + (answer.OrderedOptionIds is null ? 0 : 1);
        Guard.Against(fields != 1, "Provide exactly one answer field per question.");

        var max = snapshot.MaximumScore;
        if (question.Kind is Choice or WordBank && answer.OptionId is { } option
            && question.Options.Any(x => x.Id == option) && key.OptionId is { } correct)
            return ObjectiveScoring.ScoreChoice(option, correct, max);
        if (question.Kind == Boolean && answer.Value is { } value && key.Value is { } correctValue)
            return ObjectiveScoring.ScoreBoolean(value, correctValue, max);
        if (question.Kind is FillBlank or ExactText && answer.Text is { Length: <= 4000 } text && !text.Contains('\0'))
            return key.AcceptedAnswers!.Contains(text, StringComparer.Ordinal) ? max : 0m;
        if (question.Kind == WordOrder && answer.OrderedOptionIds is { } ordered
            && ordered.Count == question.Options.Length && ordered.Distinct().Count() == ordered.Count
            && ordered.All(id => question.Options.Any(x => x.Id == id)))
        {
            var tokens = question.Options.ToDictionary(x => x.Id, x => x.Text);
            return key.OrderedOptionIds!.Select(id => tokens[id]).SequenceEqual(ordered.Select(id => tokens[id]), StringComparer.Ordinal)
                ? max : 0m;
        }
        throw new DomainException("The answer is not valid for this question.");
    }

    internal static Presentation ReadPresentation(AssessmentAttemptQuestion snapshot) =>
        JsonSerializer.Deserialize<Presentation>(snapshot.OptionsSnapshotJson)!;

    private static bool ValidTextKeys(IReadOnlyList<string?>? answers) =>
        answers is { Count: >= 1 and <= 20 }
        && answers.All(x => !string.IsNullOrWhiteSpace(x) && x.Length <= 4000 && !x.Contains('\0'))
        && answers.Distinct(StringComparer.Ordinal).Count() == answers.Count;

    private static bool IsPermutation(IReadOnlyList<int>? indices, int count) =>
        indices?.Count == count && indices.Distinct().Count() == count && indices.All(i => i >= 0 && i < count);

    private static bool HasOneBlank(string prompt)
    {
        var index = prompt.IndexOf(Blank, StringComparison.Ordinal);
        return index >= 0 && prompt.IndexOf(Blank, index + Blank.Length, StringComparison.Ordinal) < 0;
    }

    private static StateConflictException InvalidQuestion() => new("The assessment contains an invalid or unsupported question.");

    internal sealed record Presentation(string Kind, ObjectiveOptionDto[] Options);
    private sealed record Key(Guid? OptionId, bool? Value, string[]? AcceptedAnswers = null, Guid[]? OrderedOptionIds = null);
}
