using LanguagePlatform.Application.Common;
using LanguagePlatform.Application.CourseContent;
using LanguagePlatform.Domain.Assessment;
using LanguagePlatform.Domain.Catalog;
using LanguagePlatform.Domain.Common;
using LanguagePlatform.Domain.CourseContent;
using LanguagePlatform.Domain.LessonEngine;
using LanguagePlatform.Domain.Platform;
using LanguagePlatform.Domain.Reading;
using LanguagePlatform.Infrastructure.Assessment;
using LanguagePlatform.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using AssessmentEntity = LanguagePlatform.Domain.Assessment.Assessment;

namespace LanguagePlatform.Infrastructure.CourseContent;

public sealed class CurriculumAuthoringService(LanguagePlatformDbContext db)
{
    public async Task<CurriculumCourseDto> CreateCourseAsync(CreateCurriculumCourse request, CancellationToken ct)
    {
        var turkish = LanguageCode.Create("tr");
        var arabic = LanguageCode.Create("ar");
        var pathId = await db.LearningPaths.Where(x => x.IsActive && x.SourceLanguage.IsActive && x.TargetLanguage.IsActive
            && x.SourceLanguage.Code == turkish && x.TargetLanguage.Code == arabic).Select(x => x.Id).SingleOrDefaultAsync(ct);
        var programId = await db.LearningPrograms.Where(x => x.IsActive && x.Code == "modern-language")
            .Select(x => x.Id).SingleOrDefaultAsync(ct);
        if (pathId == Guid.Empty || programId == Guid.Empty)
            throw new StateConflictException("Seed the active Turkish-to-Arabic path and Modern Language program first.");

        var course = Course.Create(pathId, programId, request.Slug, request.Title, request.Description);
        course.EnableFiveStageCurriculum();
        db.Add(course);
        var levels = new List<CurriculumLevelDto>(FiveStageCurriculum.Levels.Count);
        for (var index = 0; index < FiveStageCurriculum.Levels.Count; index++)
        {
            var code = FiveStageCurriculum.Levels[index];
            var level = new CourseLevel { CourseId = course.Id, Code = code, DisplayOrder = index + 1 };
            var module = new CourseModule { CourseLevelId = level.Id, Title = code, DisplayOrder = 1 };
            db.AddRange(level, module, new CourseUnit { CourseModuleId = module.Id, Title = code, DisplayOrder = 1 });
            levels.Add(new CurriculumLevelDto(level.Id, code, index + 1, FiveStageCurriculum.SlotsPerLevel));
        }
        await db.SaveChangesAsync(ct);
        return new CurriculumCourseDto(course.Id, levels);
    }

    public async Task<CurriculumDraftDto> CreateVersionAsync(Guid actorId, Guid courseId, Guid levelId, int position,
        CreateCurriculumVersion request, CancellationToken ct)
    {
        Guard.Against(position is < 1 or > FiveStageCurriculum.SlotsPerLevel, "Lesson position must be between 1 and 20.");
        Guard.Against(!Enum.IsDefined(request.AttemptSelection), "Invalid attempt selection policy.");
        Guard.Against(request.Stages is null || request.Stages.Count > FiveStageCurriculum.Stages.Count
            || request.Stages.Any(x => x is null || !FiveStageCurriculum.Stages.Contains(x.Kind, StringComparer.Ordinal))
            || request.Stages.Select(x => x.Kind).Distinct(StringComparer.Ordinal).Count() != request.Stages.Count,
            "Stage definitions must use unique supported stage codes.");
        var stageInputs = request.Stages!.ToDictionary(x => x.Kind, StringComparer.Ordinal);
        Guard.Against(request.ApproveWeights && (stageInputs.Count != FiveStageCurriculum.Stages.Count
            || stageInputs.Values.Any(x => x.Weight is null) || stageInputs.Values.Sum(x => x.Weight) != 100m),
            "Approval requires five explicit weights totaling 100.");
        var title = Guard.Text(request.Title, 200, nameof(request.Title));
        var target = await (from course in db.Courses
            join level in db.Set<CourseLevel>() on course.Id equals level.CourseId
            join module in db.Set<CourseModule>() on level.Id equals module.CourseLevelId
            join unit in db.Set<CourseUnit>() on module.Id equals unit.CourseModuleId
            where course.Id == courseId && course.UsesFiveStageCurriculum && course.Status != CourseStatus.Archived
                && level.Id == levelId && module.DisplayOrder == 1 && unit.DisplayOrder == 1
            select new { UnitId = unit.Id, course.LearningPath.SourceLanguageId, course.LearningPath.TargetLanguageId })
            .SingleOrDefaultAsync(ct) ?? throw new ResourceNotFoundException();
        var lesson = await db.Set<Lesson>().SingleOrDefaultAsync(x => x.CurriculumLevelId == levelId
            && x.CurriculumPosition == position, ct);
        if (lesson is null)
        {
            lesson = new Lesson
            {
                CourseUnitId = target.UnitId, Slug = FormattableString.Invariant($"lesson-{position}"),
                DisplayOrder = position, CurriculumLevelId = levelId, CurriculumPosition = position
            };
            db.Add(lesson);
        }
        Guard.Against(lesson.IsArchived || lesson.CourseUnitId != target.UnitId, "This lesson slot cannot be edited.");
        var next = (await db.Set<LessonVersion>().Where(x => x.LessonId == lesson.Id)
            .MaxAsync(x => (int?)x.VersionNumber, ct) ?? 0) + 1;
        var version = new LessonVersion
        {
            LessonId = lesson.Id, VersionNumber = next, Title = title, PassingScore = FiveStageCurriculum.PassingScore,
            UsesFiveStageCurriculum = true, WeightsApproved = request.ApproveWeights, AttemptSelection = request.AttemptSelection
        };
        db.Add(version);
        for (var index = 0; index < FiveStageCurriculum.Stages.Count; index++)
        {
            var kind = FiveStageCurriculum.Stages[index];
            var input = stageInputs.GetValueOrDefault(kind);
            var weight = Guard.Percentage(input?.Weight ?? 0m);
            Guard.Against(decimal.Round(weight, 4) != weight, "A weight may have at most four decimal places.");
            Guard.Against(input is { MaximumAttempts: < 1 or > 100 }, "Attempt limits must be between 1 and 100.");
            var stage = new LessonStage
            {
                LessonVersionId = version.Id, StageType = kind, DisplayOrder = index + 1, Weight = weight,
                IsRequired = true, IsActive = true, MinimumScore = 0m, MaximumAttempts = input?.MaximumAttempts ?? 1,
                EstimatedDurationSeconds = 0, SettingsSchemaVersion = 1, SettingsJson = CurriculumStageSettings.Create(input)
            };
            db.Add(stage);
            AddText(stage.Id, target.TargetLanguageId, input?.ArabicText);
            AddText(stage.Id, target.SourceLanguageId, input?.TurkishText);
            if (input?.Questions is { Count: > 0 } questions)
            {
                AddQuestions(actorId, target.TargetLanguageId, stage, questions);
            }
            else if (kind == "speaking" && input?.EvaluationRubric is not null)
            {
                db.Add(NewAssessment(stage));
            }
        }
        await db.SaveChangesAsync(ct);
        return new CurriculumDraftDto(lesson.Id, version.Id, next, version.Version, version.WeightsApproved);
    }

    public async Task<CurriculumDraftDto> ReviewAsync(Guid actorId, Guid versionId, uint expectedVersion, CancellationToken ct)
    {
        var version = await db.Set<LessonVersion>().SingleOrDefaultAsync(x => x.Id == versionId && x.UsesFiveStageCurriculum, ct)
            ?? throw new ResourceNotFoundException();
        if (version.Version != expectedVersion) throw new StateConflictException("The draft revision has changed.");
        Guard.Against(await db.Set<ReadingMaterial>().AnyAsync(x => x.LessonVersionId == versionId
            && x.OriginalPdf != null && x.ReviewedAtUtc == null, ct), "Approve the PDF reading lines before lesson review.");
        version.SubmitForReview();
        db.Add(new AuditLog
        {
            ActorId = actorId, Action = "content.curriculum.review", EntityType = nameof(LessonVersion),
            EntityId = version.Id, OccurredAtUtc = DateTime.UtcNow, CorrelationId = Guid.NewGuid().ToString("N"),
            RedactedChangesJson = "{}"
        });
        await db.SaveChangesAsync(ct);
        return new CurriculumDraftDto(version.LessonId, version.Id, version.VersionNumber, version.Version, version.WeightsApproved);
    }

    public async Task PublishCourseAsync(Guid courseId, CancellationToken ct)
    {
        var course = await db.Courses.SingleOrDefaultAsync(x => x.Id == courseId && x.UsesFiveStageCurriculum, ct)
            ?? throw new ResourceNotFoundException();
        if (course.Status == CourseStatus.Published) return;
        var hasFirstLesson = await (from level in db.Set<CourseLevel>()
            join lesson in db.Set<Lesson>() on (Guid?)level.Id equals lesson.CurriculumLevelId
            join version in db.Set<LessonVersion>() on lesson.Id equals version.LessonId
            join publication in db.Set<ContentPublication>() on version.Id equals publication.LessonVersionId
            where level.CourseId == courseId && level.DisplayOrder == 1 && lesson.CurriculumPosition == 1 && !lesson.IsArchived
                && version.UsesFiveStageCurriculum && version.Status == PublicationState.Published && publication.WithdrawnAtUtc == null
            select lesson.Id).AnyAsync(ct);
        Guard.Against(!hasFirstLesson, "Publish the first A1 lesson before releasing the course.");
        if (course.Status == CourseStatus.Draft) course.SubmitForReview();
        course.Publish();
        await db.SaveChangesAsync(ct);
    }

    private void AddText(Guid stageId, Guid languageId, string? text)
    {
        if (text is null) return;
        Guard.Against(text.Length > 64000 || string.IsNullOrWhiteSpace(text) || text.Contains('\0'),
            "Stage text must contain 1 to 64000 characters.");
        db.Add(new LessonStageContent { LessonStageId = stageId, LanguageId = languageId, Body = text });
    }

    private void AddQuestions(Guid actorId, Guid languageId, LessonStage stage, IReadOnlyList<DraftQuestion> questions)
    {
        Guard.Against(questions.Count > (stage.StageType == "reading" ? 10 : 100), "Too many questions for this stage.");
        var assessment = NewAssessment(stage);
        var bank = new QuestionBank { LanguageId = languageId, OwnerId = actorId, Name = stage.StageType };
        db.AddRange(assessment, bank);
        for (var index = 0; index < questions.Count; index++)
        {
            var input = questions[index];
            Guard.Against(input is null, "Question is required.");
            Guard.Against(!ExerciseQuestions.Supports(stage.StageType, input!.Kind),
                "This question type is unavailable for the selected stage.");
            var question = CreateQuestion(bank.Id, input!, index + 1);
            db.AddRange(question, new AssessmentQuestion
            {
                AssessmentId = assessment.Id, QuestionId = question.Id, DisplayOrder = index + 1, MaximumScore = input!.MaximumScore
            });
            if (input!.Options is { } options)
                for (var order = 0; order < options.Count; order++)
                    db.Add(new QuestionOption
                    {
                        QuestionId = question.Id, DisplayOrder = order + 1, Text = options[order].Text,
                        IsCorrect = options[order].IsCorrect
                    });
        }
    }

    private static Question CreateQuestion(Guid bankId, DraftQuestion input, int order)
    {
        var prompt = Guard.Text(input.Prompt, 16000, nameof(input.Prompt));
        Guard.Against(prompt.Contains('\0'), "Question prompt contains an unsupported character.");
        var key = ExerciseQuestions.CreateKey(input);
        return new Question
        {
            QuestionBankId = bankId, Code = FormattableString.Invariant($"question-{order}"), VersionNumber = 1,
            QuestionType = input.Kind, Prompt = prompt, AnswerKeyJson = key
        };
    }

    private static AssessmentEntity NewAssessment(LessonStage stage) => new()
    {
        LessonStageId = stage.Id, Title = stage.StageType, PassingScore = 0, MaximumAttempts = stage.MaximumAttempts
    };
}
