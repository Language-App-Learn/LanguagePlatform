namespace LanguagePlatform.Application.Identity;

public static class Permissions
{
    public const string ClaimType = "permission";
    public const string ContentEdit = "content.edit";
    public const string ContentPublish = "content.publish";
    public const string AssessmentEvaluate = "assessment.evaluate";
    public const string StudentsManage = "students.manage";
    public const string BillingManage = "billing.manage";
    public static IReadOnlyList<string> All { get; } =
        [ContentEdit, ContentPublish, AssessmentEvaluate, StudentsManage, BillingManage];
}

public interface ICurrentActor
{
    Guid? UserId { get; }
    bool HasPermission(string permission);
}
