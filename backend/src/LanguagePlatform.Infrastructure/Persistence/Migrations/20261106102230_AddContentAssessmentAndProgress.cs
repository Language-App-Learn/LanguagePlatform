using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddContentAssessmentAndProgress : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "achievements",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_achievements", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "course_categories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_categories", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "course_instructors",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    can_edit = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_instructors", x => x.id);
                    table.ForeignKey(
                        name: "FK_course_instructors_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_course_instructors_identity_users_user_id",
                        column: x => x.user_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_levels",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_levels", x => x.id);
                    table.CheckConstraint("ck_course_levels_1", "display_order > 0");
                    table.ForeignKey(
                        name: "FK_course_levels_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_localizations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_localizations", x => x.id);
                    table.ForeignKey(
                        name: "FK_course_localizations_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_course_localizations_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_prerequisites",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    required_course_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_prerequisites", x => x.id);
                    table.CheckConstraint("ck_course_prerequisites_1", "course_id <> required_course_id");
                    table.ForeignKey(
                        name: "FK_course_prerequisites_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_course_prerequisites_courses_required_course_id",
                        column: x => x.required_course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "enrollments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    enrolled_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    completed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_enrollments", x => x.id);
                    table.CheckConstraint("ck_enrollments_1", "status IN ('Active','Completed','Withdrawn')");
                    table.CheckConstraint("ck_enrollments_2", "completed_at_utc IS NULL OR completed_at_utc >= enrolled_at_utc");
                    table.ForeignKey(
                        name: "FK_enrollments_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_enrollments_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "learning_streaks",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    activity_date = table.Column<DateOnly>(type: "date", nullable: false),
                    active_minutes = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_learning_streaks", x => x.id);
                    table.CheckConstraint("ck_learning_streaks_1", "active_minutes > 0");
                    table.ForeignKey(
                        name: "FK_learning_streaks_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "question_banks",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    owner_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_question_banks", x => x.id);
                    table.ForeignKey(
                        name: "FK_question_banks_identity_users_owner_id",
                        column: x => x.owner_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_question_banks_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "scoring_rubrics",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    criteria_json = table.Column<string>(type: "jsonb", nullable: false),
                    maximum_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_scoring_rubrics", x => x.id);
                    table.CheckConstraint("ck_scoring_rubrics_1", "version_number > 0");
                    table.CheckConstraint("ck_scoring_rubrics_2", "maximum_score > 0");
                });

            migrationBuilder.CreateTable(
                name: "student_achievements",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    achievement_id = table.Column<Guid>(type: "uuid", nullable: false),
                    awarded_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_student_achievements", x => x.id);
                    table.ForeignKey(
                        name: "FK_student_achievements_achievements_achievement_id",
                        column: x => x.achievement_id,
                        principalTable: "achievements",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_student_achievements_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_category_assignments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_category_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_category_assignments", x => x.id);
                    table.ForeignKey(
                        name: "FK_course_category_assignments_course_categories_course_catego~",
                        column: x => x.course_category_id,
                        principalTable: "course_categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_course_category_assignments_courses_course_id",
                        column: x => x.course_id,
                        principalTable: "courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_modules",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_level_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_modules", x => x.id);
                    table.CheckConstraint("ck_course_modules_1", "display_order > 0");
                    table.ForeignKey(
                        name: "FK_course_modules_course_levels_course_level_id",
                        column: x => x.course_level_id,
                        principalTable: "course_levels",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_progress",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    enrollment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    completed_lesson_count = table.Column<int>(type: "integer", nullable: false),
                    updated_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_progress", x => x.id);
                    table.CheckConstraint("ck_course_progress_1", "completed_lesson_count >= 0");
                    table.ForeignKey(
                        name: "FK_course_progress_enrollments_enrollment_id",
                        column: x => x.enrollment_id,
                        principalTable: "enrollments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "learning_activities",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    enrollment_id = table.Column<Guid>(type: "uuid", nullable: true),
                    activity_type = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    occurred_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    duration_seconds = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_learning_activities", x => x.id);
                    table.CheckConstraint("ck_learning_activities_1", "duration_seconds >= 0");
                    table.ForeignKey(
                        name: "FK_learning_activities_enrollments_enrollment_id",
                        column: x => x.enrollment_id,
                        principalTable: "enrollments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_learning_activities_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "questions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    question_bank_id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    question_type = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    prompt = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    answer_key_json = table.Column<string>(type: "jsonb", nullable: false),
                    is_archived = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_questions", x => x.id);
                    table.CheckConstraint("ck_questions_1", "version_number > 0");
                    table.ForeignKey(
                        name: "FK_questions_question_banks_question_bank_id",
                        column: x => x.question_bank_id,
                        principalTable: "question_banks",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "course_units",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_module_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course_units", x => x.id);
                    table.CheckConstraint("ck_course_units_1", "display_order > 0");
                    table.ForeignKey(
                        name: "FK_course_units_course_modules_course_module_id",
                        column: x => x.course_module_id,
                        principalTable: "course_modules",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "question_localizations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    question_id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    prompt = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_question_localizations", x => x.id);
                    table.ForeignKey(
                        name: "FK_question_localizations_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_question_localizations_questions_question_id",
                        column: x => x.question_id,
                        principalTable: "questions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "question_options",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    question_id = table.Column<Guid>(type: "uuid", nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false),
                    text = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    is_correct = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_question_options", x => x.id);
                    table.CheckConstraint("ck_question_options_1", "display_order > 0");
                    table.ForeignKey(
                        name: "FK_question_options_questions_question_id",
                        column: x => x.question_id,
                        principalTable: "questions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lessons",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    course_unit_id = table.Column<Guid>(type: "uuid", nullable: false),
                    slug = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false),
                    is_archived = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lessons", x => x.id);
                    table.CheckConstraint("ck_lessons_1", "display_order > 0");
                    table.ForeignKey(
                        name: "FK_lessons_course_units_course_unit_id",
                        column: x => x.course_unit_id,
                        principalTable: "course_units",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_prerequisites",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_id = table.Column<Guid>(type: "uuid", nullable: false),
                    required_lesson_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_prerequisites", x => x.id);
                    table.CheckConstraint("ck_lesson_prerequisites_1", "lesson_id <> required_lesson_id");
                    table.ForeignKey(
                        name: "FK_lesson_prerequisites_lessons_lesson_id",
                        column: x => x.lesson_id,
                        principalTable: "lessons",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_prerequisites_lessons_required_lesson_id",
                        column: x => x.required_lesson_id,
                        principalTable: "lessons",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_versions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_id = table.Column<Guid>(type: "uuid", nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    passing_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    attempt_selection = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    published_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_versions", x => x.id);
                    table.CheckConstraint("ck_lesson_versions_1", "version_number > 0");
                    table.CheckConstraint("ck_lesson_versions_2", "passing_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_lesson_versions_3", "(status = 'Published') = (published_at_utc IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_lesson_versions_lessons_lesson_id",
                        column: x => x.lesson_id,
                        principalTable: "lessons",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "content_publications",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    published_by = table.Column<Guid>(type: "uuid", nullable: false),
                    published_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    withdrawn_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    reason = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_content_publications", x => x.id);
                    table.ForeignKey(
                        name: "FK_content_publications_identity_users_published_by",
                        column: x => x.published_by,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_content_publications_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_localizations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_localizations", x => x.id);
                    table.ForeignKey(
                        name: "FK_lesson_localizations_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_localizations_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_media_references",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    media_asset_id = table.Column<Guid>(type: "uuid", nullable: false),
                    purpose = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_media_references", x => x.id);
                    table.ForeignKey(
                        name: "FK_lesson_media_references_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_media_references_media_assets_media_asset_id",
                        column: x => x.media_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_progress",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    enrollment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    is_passed = table.Column<bool>(type: "boolean", nullable: false),
                    updated_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_progress", x => x.id);
                    table.UniqueConstraint("AK_lesson_progress_id_lesson_version_id", x => new { x.id, x.lesson_version_id });
                    table.CheckConstraint("ck_lesson_progress_1", "score BETWEEN 0 AND 100");
                    table.ForeignKey(
                        name: "FK_lesson_progress_enrollments_enrollment_id",
                        column: x => x.enrollment_id,
                        principalTable: "enrollments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_progress_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_stages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    stage_type = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false),
                    weight = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    is_required = table.Column<bool>(type: "boolean", nullable: false),
                    minimum_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    maximum_attempts = table.Column<int>(type: "integer", nullable: false),
                    estimated_duration_seconds = table.Column<int>(type: "integer", nullable: false),
                    settings_schema_version = table.Column<int>(type: "integer", nullable: false),
                    settings_json = table.Column<string>(type: "jsonb", nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_stages", x => x.id);
                    table.UniqueConstraint("AK_lesson_stages_id_lesson_version_id", x => new { x.id, x.lesson_version_id });
                    table.CheckConstraint("ck_lesson_stages_1", "display_order > 0");
                    table.CheckConstraint("ck_lesson_stages_2", "weight BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_lesson_stages_3", "minimum_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_lesson_stages_4", "maximum_attempts > 0");
                    table.CheckConstraint("ck_lesson_stages_5", "estimated_duration_seconds >= 0");
                    table.CheckConstraint("ck_lesson_stages_6", "settings_schema_version > 0");
                    table.ForeignKey(
                        name: "FK_lesson_stages_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "assessments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_stage_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    passing_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    maximum_attempts = table.Column<int>(type: "integer", nullable: false),
                    time_limit_seconds = table.Column<int>(type: "integer", nullable: true),
                    is_published = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_assessments", x => x.id);
                    table.CheckConstraint("ck_assessments_1", "passing_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_assessments_2", "maximum_attempts > 0");
                    table.CheckConstraint("ck_assessments_3", "time_limit_seconds IS NULL OR time_limit_seconds > 0");
                    table.ForeignKey(
                        name: "FK_assessments_lesson_stages_lesson_stage_id",
                        column: x => x.lesson_stage_id,
                        principalTable: "lesson_stages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "lesson_stage_contents",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_stage_id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    body = table.Column<string>(type: "character varying(64000)", maxLength: 64000, nullable: true),
                    media_asset_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_stage_contents", x => x.id);
                    table.CheckConstraint("ck_lesson_stage_contents_1", "body IS NOT NULL OR media_asset_id IS NOT NULL");
                    table.ForeignKey(
                        name: "FK_lesson_stage_contents_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_stage_contents_lesson_stages_lesson_stage_id",
                        column: x => x.lesson_stage_id,
                        principalTable: "lesson_stages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_lesson_stage_contents_media_assets_media_asset_id",
                        column: x => x.media_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "stage_dependencies",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    stage_id = table.Column<Guid>(type: "uuid", nullable: false),
                    required_stage_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_stage_dependencies", x => x.id);
                    table.CheckConstraint("ck_stage_dependencies_1", "stage_id <> required_stage_id");
                    table.ForeignKey(
                        name: "FK_stage_dependencies_lesson_stages_required_stage_id_lesson_v~",
                        columns: x => new { x.required_stage_id, x.lesson_version_id },
                        principalTable: "lesson_stages",
                        principalColumns: new[] { "id", "lesson_version_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_stage_dependencies_lesson_stages_stage_id_lesson_version_id",
                        columns: x => new { x.stage_id, x.lesson_version_id },
                        principalTable: "lesson_stages",
                        principalColumns: new[] { "id", "lesson_version_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_stage_dependencies_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "stage_progress",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_progress_id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_stage_id = table.Column<Guid>(type: "uuid", nullable: false),
                    score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    is_completed = table.Column<bool>(type: "boolean", nullable: false),
                    updated_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_stage_progress", x => x.id);
                    table.CheckConstraint("ck_stage_progress_1", "score BETWEEN 0 AND 100");
                    table.ForeignKey(
                        name: "FK_stage_progress_lesson_progress_lesson_progress_id_lesson_ve~",
                        columns: x => new { x.lesson_progress_id, x.lesson_version_id },
                        principalTable: "lesson_progress",
                        principalColumns: new[] { "id", "lesson_version_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_stage_progress_lesson_stages_lesson_stage_id_lesson_version~",
                        columns: x => new { x.lesson_stage_id, x.lesson_version_id },
                        principalTable: "lesson_stages",
                        principalColumns: new[] { "id", "lesson_version_id" },
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "assessment_attempts",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    assessment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    started_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    completed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: true),
                    maximum_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    attempt_number = table.Column<int>(type: "integer", nullable: false),
                    idempotency_key = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_assessment_attempts", x => x.id);
                    table.CheckConstraint("ck_assessment_attempts_1", "attempt_number > 0");
                    table.CheckConstraint("ck_assessment_attempts_2", "maximum_score > 0");
                    table.CheckConstraint("ck_assessment_attempts_3", "score IS NULL OR (score >= 0 AND score <= maximum_score)");
                    table.CheckConstraint("ck_assessment_attempts_4", "completed_at_utc IS NULL OR completed_at_utc >= started_at_utc");
                    table.ForeignKey(
                        name: "FK_assessment_attempts_assessments_assessment_id",
                        column: x => x.assessment_id,
                        principalTable: "assessments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_assessment_attempts_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "assessment_questions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    assessment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    question_id = table.Column<Guid>(type: "uuid", nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false),
                    maximum_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_assessment_questions", x => x.id);
                    table.CheckConstraint("ck_assessment_questions_1", "display_order > 0");
                    table.CheckConstraint("ck_assessment_questions_2", "maximum_score > 0");
                    table.ForeignKey(
                        name: "FK_assessment_questions_assessments_assessment_id",
                        column: x => x.assessment_id,
                        principalTable: "assessments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_assessment_questions_questions_question_id",
                        column: x => x.question_id,
                        principalTable: "questions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "stage_attempts",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    stage_progress_id = table.Column<Guid>(type: "uuid", nullable: false),
                    attempt_number = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: true),
                    started_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    completed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    idempotency_key = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_stage_attempts", x => x.id);
                    table.CheckConstraint("ck_stage_attempts_1", "attempt_number > 0");
                    table.CheckConstraint("ck_stage_attempts_2", "score IS NULL OR score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_stage_attempts_3", "completed_at_utc IS NULL OR completed_at_utc >= started_at_utc");
                    table.ForeignKey(
                        name: "FK_stage_attempts_stage_progress_stage_progress_id",
                        column: x => x.stage_progress_id,
                        principalTable: "stage_progress",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "assessment_attempt_questions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    assessment_attempt_id = table.Column<Guid>(type: "uuid", nullable: false),
                    question_id = table.Column<Guid>(type: "uuid", nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false),
                    prompt_snapshot = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    answer_key_snapshot_json = table.Column<string>(type: "jsonb", nullable: false),
                    options_snapshot_json = table.Column<string>(type: "jsonb", nullable: false),
                    maximum_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_assessment_attempt_questions", x => x.id);
                    table.CheckConstraint("ck_assessment_attempt_questions_1", "maximum_score > 0");
                    table.ForeignKey(
                        name: "FK_assessment_attempt_questions_assessment_attempts_assessment~",
                        column: x => x.assessment_attempt_id,
                        principalTable: "assessment_attempts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_assessment_attempt_questions_questions_question_id",
                        column: x => x.question_id,
                        principalTable: "questions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "assessment_results",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    assessment_attempt_id = table.Column<Guid>(type: "uuid", nullable: false),
                    stage_attempt_id = table.Column<Guid>(type: "uuid", nullable: false),
                    recorded_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_assessment_results", x => x.id);
                    table.ForeignKey(
                        name: "FK_assessment_results_assessment_attempts_assessment_attempt_id",
                        column: x => x.assessment_attempt_id,
                        principalTable: "assessment_attempts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_assessment_results_stage_attempts_stage_attempt_id",
                        column: x => x.stage_attempt_id,
                        principalTable: "stage_attempts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "student_answers",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    attempt_question_id = table.Column<Guid>(type: "uuid", nullable: false),
                    answer_text = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: true),
                    selected_options_json = table.Column<string>(type: "jsonb", nullable: false),
                    submitted_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_student_answers", x => x.id);
                    table.ForeignKey(
                        name: "FK_student_answers_assessment_attempt_questions_attempt_questi~",
                        column: x => x.attempt_question_id,
                        principalTable: "assessment_attempt_questions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "answer_evaluations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_answer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    scoring_rubric_id = table.Column<Guid>(type: "uuid", nullable: false),
                    evaluator_id = table.Column<Guid>(type: "uuid", nullable: true),
                    score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    feedback = table.Column<string>(type: "character varying(8000)", maxLength: 8000, nullable: true),
                    evaluated_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    method = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_answer_evaluations", x => x.id);
                    table.CheckConstraint("ck_answer_evaluations_1", "score >= 0");
                    table.ForeignKey(
                        name: "FK_answer_evaluations_identity_users_evaluator_id",
                        column: x => x.evaluator_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_answer_evaluations_scoring_rubrics_scoring_rubric_id",
                        column: x => x.scoring_rubric_id,
                        principalTable: "scoring_rubrics",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_answer_evaluations_student_answers_student_answer_id",
                        column: x => x.student_answer_id,
                        principalTable: "student_answers",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_achievements_code",
                table: "achievements",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_answer_evaluations_evaluator_id",
                table: "answer_evaluations",
                column: "evaluator_id");

            migrationBuilder.CreateIndex(
                name: "IX_answer_evaluations_scoring_rubric_id",
                table: "answer_evaluations",
                column: "scoring_rubric_id");

            migrationBuilder.CreateIndex(
                name: "IX_answer_evaluations_student_answer_id",
                table: "answer_evaluations",
                column: "student_answer_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempt_questions_assessment_attempt_id_display_~",
                table: "assessment_attempt_questions",
                columns: new[] { "assessment_attempt_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempt_questions_assessment_attempt_id_question~",
                table: "assessment_attempt_questions",
                columns: new[] { "assessment_attempt_id", "question_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempt_questions_question_id",
                table: "assessment_attempt_questions",
                column: "question_id");

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempts_assessment_id",
                table: "assessment_attempts",
                column: "assessment_id");

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempts_student_id_assessment_id_attempt_number",
                table: "assessment_attempts",
                columns: new[] { "student_id", "assessment_id", "attempt_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_attempts_student_id_idempotency_key",
                table: "assessment_attempts",
                columns: new[] { "student_id", "idempotency_key" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_questions_assessment_id_display_order",
                table: "assessment_questions",
                columns: new[] { "assessment_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_questions_assessment_id_question_id",
                table: "assessment_questions",
                columns: new[] { "assessment_id", "question_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_questions_question_id",
                table: "assessment_questions",
                column: "question_id");

            migrationBuilder.CreateIndex(
                name: "IX_assessment_results_assessment_attempt_id",
                table: "assessment_results",
                column: "assessment_attempt_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessment_results_stage_attempt_id",
                table: "assessment_results",
                column: "stage_attempt_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_assessments_lesson_stage_id",
                table: "assessments",
                column: "lesson_stage_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_content_publications_lesson_version_id",
                table: "content_publications",
                column: "lesson_version_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_content_publications_published_by",
                table: "content_publications",
                column: "published_by");

            migrationBuilder.CreateIndex(
                name: "IX_course_categories_code",
                table: "course_categories",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_category_assignments_course_category_id",
                table: "course_category_assignments",
                column: "course_category_id");

            migrationBuilder.CreateIndex(
                name: "IX_course_category_assignments_course_id_course_category_id",
                table: "course_category_assignments",
                columns: new[] { "course_id", "course_category_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_instructors_course_id_user_id",
                table: "course_instructors",
                columns: new[] { "course_id", "user_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_instructors_user_id",
                table: "course_instructors",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_course_levels_course_id_code",
                table: "course_levels",
                columns: new[] { "course_id", "code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_levels_course_id_display_order",
                table: "course_levels",
                columns: new[] { "course_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_localizations_course_id_language_id",
                table: "course_localizations",
                columns: new[] { "course_id", "language_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_localizations_language_id",
                table: "course_localizations",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_course_modules_course_level_id_display_order",
                table: "course_modules",
                columns: new[] { "course_level_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_prerequisites_course_id_required_course_id",
                table: "course_prerequisites",
                columns: new[] { "course_id", "required_course_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_prerequisites_required_course_id",
                table: "course_prerequisites",
                column: "required_course_id");

            migrationBuilder.CreateIndex(
                name: "IX_course_progress_enrollment_id",
                table: "course_progress",
                column: "enrollment_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_units_course_module_id_display_order",
                table: "course_units",
                columns: new[] { "course_module_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_enrollments_course_id",
                table: "enrollments",
                column: "course_id");

            migrationBuilder.CreateIndex(
                name: "IX_enrollments_student_id_course_id",
                table: "enrollments",
                columns: new[] { "student_id", "course_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_learning_activities_enrollment_id",
                table: "learning_activities",
                column: "enrollment_id");

            migrationBuilder.CreateIndex(
                name: "IX_learning_activities_student_id_occurred_at_utc",
                table: "learning_activities",
                columns: new[] { "student_id", "occurred_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_learning_streaks_student_id_activity_date",
                table: "learning_streaks",
                columns: new[] { "student_id", "activity_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_localizations_language_id",
                table: "lesson_localizations",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_localizations_lesson_version_id_language_id",
                table: "lesson_localizations",
                columns: new[] { "lesson_version_id", "language_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_media_references_lesson_version_id_media_asset_id_pu~",
                table: "lesson_media_references",
                columns: new[] { "lesson_version_id", "media_asset_id", "purpose" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_media_references_media_asset_id",
                table: "lesson_media_references",
                column: "media_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_prerequisites_lesson_id_required_lesson_id",
                table: "lesson_prerequisites",
                columns: new[] { "lesson_id", "required_lesson_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_prerequisites_required_lesson_id",
                table: "lesson_prerequisites",
                column: "required_lesson_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_progress_enrollment_id_lesson_version_id",
                table: "lesson_progress",
                columns: new[] { "enrollment_id", "lesson_version_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_progress_lesson_version_id",
                table: "lesson_progress",
                column: "lesson_version_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_stage_contents_language_id",
                table: "lesson_stage_contents",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_stage_contents_lesson_stage_id_language_id",
                table: "lesson_stage_contents",
                columns: new[] { "lesson_stage_id", "language_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_stage_contents_media_asset_id",
                table: "lesson_stage_contents",
                column: "media_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_stages_lesson_version_id_display_order",
                table: "lesson_stages",
                columns: new[] { "lesson_version_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_versions_lesson_id_version_number",
                table: "lesson_versions",
                columns: new[] { "lesson_id", "version_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lessons_course_unit_id_display_order",
                table: "lessons",
                columns: new[] { "course_unit_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lessons_course_unit_id_slug",
                table: "lessons",
                columns: new[] { "course_unit_id", "slug" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_question_banks_language_id",
                table: "question_banks",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_question_banks_owner_id",
                table: "question_banks",
                column: "owner_id");

            migrationBuilder.CreateIndex(
                name: "IX_question_localizations_language_id",
                table: "question_localizations",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_question_localizations_question_id_language_id",
                table: "question_localizations",
                columns: new[] { "question_id", "language_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_question_options_question_id_display_order",
                table: "question_options",
                columns: new[] { "question_id", "display_order" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_questions_question_bank_id_code_version_number",
                table: "questions",
                columns: new[] { "question_bank_id", "code", "version_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_scoring_rubrics_code_version_number",
                table: "scoring_rubrics",
                columns: new[] { "code", "version_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_stage_attempts_stage_progress_id_attempt_number",
                table: "stage_attempts",
                columns: new[] { "stage_progress_id", "attempt_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_stage_attempts_stage_progress_id_idempotency_key",
                table: "stage_attempts",
                columns: new[] { "stage_progress_id", "idempotency_key" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_stage_dependencies_lesson_version_id",
                table: "stage_dependencies",
                column: "lesson_version_id");

            migrationBuilder.CreateIndex(
                name: "IX_stage_dependencies_required_stage_id_lesson_version_id",
                table: "stage_dependencies",
                columns: new[] { "required_stage_id", "lesson_version_id" });

            migrationBuilder.CreateIndex(
                name: "IX_stage_dependencies_stage_id_lesson_version_id",
                table: "stage_dependencies",
                columns: new[] { "stage_id", "lesson_version_id" });

            migrationBuilder.CreateIndex(
                name: "IX_stage_dependencies_stage_id_required_stage_id",
                table: "stage_dependencies",
                columns: new[] { "stage_id", "required_stage_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_stage_progress_lesson_progress_id_lesson_stage_id",
                table: "stage_progress",
                columns: new[] { "lesson_progress_id", "lesson_stage_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_stage_progress_lesson_progress_id_lesson_version_id",
                table: "stage_progress",
                columns: new[] { "lesson_progress_id", "lesson_version_id" });

            migrationBuilder.CreateIndex(
                name: "IX_stage_progress_lesson_stage_id_lesson_version_id",
                table: "stage_progress",
                columns: new[] { "lesson_stage_id", "lesson_version_id" });

            migrationBuilder.CreateIndex(
                name: "IX_student_achievements_achievement_id",
                table: "student_achievements",
                column: "achievement_id");

            migrationBuilder.CreateIndex(
                name: "IX_student_achievements_student_id_achievement_id",
                table: "student_achievements",
                columns: new[] { "student_id", "achievement_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_student_answers_attempt_question_id",
                table: "student_answers",
                column: "attempt_question_id",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "answer_evaluations");

            migrationBuilder.DropTable(
                name: "assessment_questions");

            migrationBuilder.DropTable(
                name: "assessment_results");

            migrationBuilder.DropTable(
                name: "content_publications");

            migrationBuilder.DropTable(
                name: "course_category_assignments");

            migrationBuilder.DropTable(
                name: "course_instructors");

            migrationBuilder.DropTable(
                name: "course_localizations");

            migrationBuilder.DropTable(
                name: "course_prerequisites");

            migrationBuilder.DropTable(
                name: "course_progress");

            migrationBuilder.DropTable(
                name: "learning_activities");

            migrationBuilder.DropTable(
                name: "learning_streaks");

            migrationBuilder.DropTable(
                name: "lesson_localizations");

            migrationBuilder.DropTable(
                name: "lesson_media_references");

            migrationBuilder.DropTable(
                name: "lesson_prerequisites");

            migrationBuilder.DropTable(
                name: "lesson_stage_contents");

            migrationBuilder.DropTable(
                name: "question_localizations");

            migrationBuilder.DropTable(
                name: "question_options");

            migrationBuilder.DropTable(
                name: "stage_dependencies");

            migrationBuilder.DropTable(
                name: "student_achievements");

            migrationBuilder.DropTable(
                name: "scoring_rubrics");

            migrationBuilder.DropTable(
                name: "student_answers");

            migrationBuilder.DropTable(
                name: "stage_attempts");

            migrationBuilder.DropTable(
                name: "course_categories");

            migrationBuilder.DropTable(
                name: "achievements");

            migrationBuilder.DropTable(
                name: "assessment_attempt_questions");

            migrationBuilder.DropTable(
                name: "stage_progress");

            migrationBuilder.DropTable(
                name: "assessment_attempts");

            migrationBuilder.DropTable(
                name: "questions");

            migrationBuilder.DropTable(
                name: "lesson_progress");

            migrationBuilder.DropTable(
                name: "assessments");

            migrationBuilder.DropTable(
                name: "question_banks");

            migrationBuilder.DropTable(
                name: "enrollments");

            migrationBuilder.DropTable(
                name: "lesson_stages");

            migrationBuilder.DropTable(
                name: "lesson_versions");

            migrationBuilder.DropTable(
                name: "lessons");

            migrationBuilder.DropTable(
                name: "course_units");

            migrationBuilder.DropTable(
                name: "course_modules");

            migrationBuilder.DropTable(
                name: "course_levels");
        }
    }
}
