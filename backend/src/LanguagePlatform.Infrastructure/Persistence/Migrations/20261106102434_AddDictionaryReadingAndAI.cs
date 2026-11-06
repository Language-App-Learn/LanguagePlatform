using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddDictionaryReadingAndAI : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ai_provider_configurations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    model = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    capability = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    secret_reference = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    is_enabled = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_provider_configurations", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "ai_tutors",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    code = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_tutors", x => x.id);
                    table.ForeignKey(
                        name: "FK_ai_tutors_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "dictionary_roots",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    letters = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    meaning = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_dictionary_roots", x => x.id);
                    table.ForeignKey(
                        name: "FK_dictionary_roots_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_materials",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    lesson_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    pdf_asset_id = table.Column<Guid>(type: "uuid", nullable: true),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    copyright_notice = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    uploaded_by = table.Column<Guid>(type: "uuid", nullable: false),
                    rights_confirmed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_materials", x => x.id);
                    table.ForeignKey(
                        name: "FK_reading_materials_identity_users_uploaded_by",
                        column: x => x.uploaded_by,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_materials_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_materials_lesson_versions_lesson_version_id",
                        column: x => x.lesson_version_id,
                        principalTable: "lesson_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_materials_media_assets_pdf_asset_id",
                        column: x => x.pdf_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "translation_history",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    source_language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    target_language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    source_text = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    translated_text = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    context = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true),
                    provider_model = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    expires_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_translation_history", x => x.id);
                    table.CheckConstraint("ck_translation_history_1", "source_language_id <> target_language_id");
                    table.CheckConstraint("ck_translation_history_2", "expires_at_utc > created_at_utc");
                    table.ForeignKey(
                        name: "FK_translation_history_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_translation_history_languages_source_language_id",
                        column: x => x.source_language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_translation_history_languages_target_language_id",
                        column: x => x.target_language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_evaluation_requests",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    stage_attempt_id = table.Column<Guid>(type: "uuid", nullable: true),
                    audio_asset_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_configuration_id = table.Column<Guid>(type: "uuid", nullable: false),
                    scoring_rubric_id = table.Column<Guid>(type: "uuid", nullable: false),
                    reference_text = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    idempotency_key = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    expires_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_evaluation_requests", x => x.id);
                    table.CheckConstraint("ck_ai_evaluation_requests_1", "expires_at_utc > created_at_utc");
                    table.ForeignKey(
                        name: "FK_ai_evaluation_requests_ai_provider_configurations_provider_~",
                        column: x => x.provider_configuration_id,
                        principalTable: "ai_provider_configurations",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_evaluation_requests_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_evaluation_requests_media_assets_audio_asset_id",
                        column: x => x.audio_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_evaluation_requests_scoring_rubrics_scoring_rubric_id",
                        column: x => x.scoring_rubric_id,
                        principalTable: "scoring_rubrics",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_evaluation_requests_stage_attempts_stage_attempt_id",
                        column: x => x.stage_attempt_id,
                        principalTable: "stage_attempts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_tutor_prompt_versions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_tutor_id = table.Column<Guid>(type: "uuid", nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    system_prompt = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    published_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_tutor_prompt_versions", x => x.id);
                    table.CheckConstraint("ck_ai_tutor_prompt_versions_1", "version_number > 0");
                    table.ForeignKey(
                        name: "FK_ai_tutor_prompt_versions_ai_tutors_ai_tutor_id",
                        column: x => x.ai_tutor_id,
                        principalTable: "ai_tutors",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "dictionary_entries",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    root_id = table.Column<Guid>(type: "uuid", nullable: true),
                    lemma = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    normalized_lemma = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    part_of_speech = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_dictionary_entries", x => x.id);
                    table.ForeignKey(
                        name: "FK_dictionary_entries_dictionary_roots_root_id",
                        column: x => x.root_id,
                        principalTable: "dictionary_roots",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_dictionary_entries_languages_language_id",
                        column: x => x.language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_passages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    reading_material_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sequence = table.Column<int>(type: "integer", nullable: false),
                    original_text = table.Column<string>(type: "character varying(64000)", maxLength: 64000, nullable: false),
                    page_number = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_passages", x => x.id);
                    table.CheckConstraint("ck_reading_passages_1", "sequence > 0");
                    table.CheckConstraint("ck_reading_passages_2", "page_number IS NULL OR page_number > 0");
                    table.ForeignKey(
                        name: "FK_reading_passages_reading_materials_reading_material_id",
                        column: x => x.reading_material_id,
                        principalTable: "reading_materials",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_sessions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    reading_material_id = table.Column<Guid>(type: "uuid", nullable: false),
                    started_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    completed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    audio_asset_id = table.Column<Guid>(type: "uuid", nullable: true),
                    expires_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_sessions", x => x.id);
                    table.CheckConstraint("ck_reading_sessions_1", "expires_at_utc > started_at_utc");
                    table.ForeignKey(
                        name: "FK_reading_sessions_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_sessions_media_assets_audio_asset_id",
                        column: x => x.audio_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_sessions_reading_materials_reading_material_id",
                        column: x => x.reading_material_id,
                        principalTable: "reading_materials",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_evaluation_results",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_evaluation_request_id = table.Column<Guid>(type: "uuid", nullable: false),
                    pronunciation_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    fluency_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    accuracy_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    overall_score = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    feedback = table.Column<string>(type: "character varying(8000)", maxLength: 8000, nullable: false),
                    model_version = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    evaluated_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    accepted_for_scoring = table.Column<bool>(type: "boolean", nullable: false),
                    reviewed_by = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_evaluation_results", x => x.id);
                    table.CheckConstraint("ck_ai_evaluation_results_1", "pronunciation_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_ai_evaluation_results_2", "fluency_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_ai_evaluation_results_3", "accuracy_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_ai_evaluation_results_4", "overall_score BETWEEN 0 AND 100");
                    table.CheckConstraint("ck_ai_evaluation_results_5", "NOT accepted_for_scoring OR reviewed_by IS NOT NULL");
                    table.ForeignKey(
                        name: "FK_ai_evaluation_results_ai_evaluation_requests_ai_evaluation_~",
                        column: x => x.ai_evaluation_request_id,
                        principalTable: "ai_evaluation_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_evaluation_results_identity_users_reviewed_by",
                        column: x => x.reviewed_by,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_processing_jobs",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_evaluation_request_id = table.Column<Guid>(type: "uuid", nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    attempt_count = table.Column<int>(type: "integer", nullable: false),
                    available_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    lease_until_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    completed_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    error_code = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    correlation_id = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_processing_jobs", x => x.id);
                    table.CheckConstraint("ck_ai_processing_jobs_1", "attempt_count >= 0");
                    table.ForeignKey(
                        name: "FK_ai_processing_jobs_ai_evaluation_requests_ai_evaluation_req~",
                        column: x => x.ai_evaluation_request_id,
                        principalTable: "ai_evaluation_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_sessions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    prompt_version_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_configuration_id = table.Column<Guid>(type: "uuid", nullable: false),
                    started_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ended_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    expires_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_sessions", x => x.id);
                    table.CheckConstraint("ck_ai_sessions_1", "expires_at_utc > started_at_utc");
                    table.CheckConstraint("ck_ai_sessions_2", "ended_at_utc IS NULL OR ended_at_utc >= started_at_utc");
                    table.ForeignKey(
                        name: "FK_ai_sessions_ai_provider_configurations_provider_configurati~",
                        column: x => x.provider_configuration_id,
                        principalTable: "ai_provider_configurations",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_sessions_ai_tutor_prompt_versions_prompt_version_id",
                        column: x => x.prompt_version_id,
                        principalTable: "ai_tutor_prompt_versions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_sessions_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "pronunciations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    dictionary_entry_id = table.Column<Guid>(type: "uuid", nullable: false),
                    media_asset_id = table.Column<Guid>(type: "uuid", nullable: false),
                    dialect_code = table.Column<string>(type: "character varying(35)", maxLength: 35, nullable: false),
                    phonetic_text = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_pronunciations", x => x.id);
                    table.ForeignKey(
                        name: "FK_pronunciations_dictionary_entries_dictionary_entry_id",
                        column: x => x.dictionary_entry_id,
                        principalTable: "dictionary_entries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_pronunciations_media_assets_media_asset_id",
                        column: x => x.media_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "student_saved_words",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    dictionary_entry_id = table.Column<Guid>(type: "uuid", nullable: false),
                    saved_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    note = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_student_saved_words", x => x.id);
                    table.ForeignKey(
                        name: "FK_student_saved_words_dictionary_entries_dictionary_entry_id",
                        column: x => x.dictionary_entry_id,
                        principalTable: "dictionary_entries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_student_saved_words_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "word_forms",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    dictionary_entry_id = table.Column<Guid>(type: "uuid", nullable: false),
                    text = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    normalized_text = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: false),
                    form_type = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_word_forms", x => x.id);
                    table.ForeignKey(
                        name: "FK_word_forms_dictionary_entries_dictionary_entry_id",
                        column: x => x.dictionary_entry_id,
                        principalTable: "dictionary_entries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "word_senses",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    dictionary_entry_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sense_number = table.Column<int>(type: "integer", nullable: false),
                    definition = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_word_senses", x => x.id);
                    table.CheckConstraint("ck_word_senses_1", "sense_number > 0");
                    table.ForeignKey(
                        name: "FK_word_senses_dictionary_entries_dictionary_entry_id",
                        column: x => x.dictionary_entry_id,
                        principalTable: "dictionary_entries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_text_segments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    reading_passage_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sequence = table.Column<int>(type: "integer", nullable: false),
                    text = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    start_offset = table.Column<int>(type: "integer", nullable: false),
                    length = table.Column<int>(type: "integer", nullable: false),
                    alignment_schema_version = table.Column<int>(type: "integer", nullable: false),
                    alignment_json = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_text_segments", x => x.id);
                    table.CheckConstraint("ck_reading_text_segments_1", "sequence > 0");
                    table.CheckConstraint("ck_reading_text_segments_2", "start_offset >= 0 AND length > 0");
                    table.CheckConstraint("ck_reading_text_segments_3", "alignment_schema_version > 0");
                    table.ForeignKey(
                        name: "FK_reading_text_segments_reading_passages_reading_passage_id",
                        column: x => x.reading_passage_id,
                        principalTable: "reading_passages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_evaluations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    reading_session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_evaluation_request_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_evaluations", x => x.id);
                    table.ForeignKey(
                        name: "FK_reading_evaluations_ai_evaluation_requests_ai_evaluation_re~",
                        column: x => x.ai_evaluation_request_id,
                        principalTable: "ai_evaluation_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_evaluations_reading_sessions_reading_session_id",
                        column: x => x.reading_session_id,
                        principalTable: "reading_sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_messages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    sequence = table.Column<int>(type: "integer", nullable: false),
                    speaker = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    text = table.Column<string>(type: "character varying(16000)", maxLength: 16000, nullable: true),
                    audio_asset_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_messages", x => x.id);
                    table.CheckConstraint("ck_ai_messages_1", "sequence > 0");
                    table.CheckConstraint("ck_ai_messages_2", "text IS NOT NULL OR audio_asset_id IS NOT NULL");
                    table.CheckConstraint("ck_ai_messages_3", "speaker IN ('Student','Tutor','System')");
                    table.ForeignKey(
                        name: "FK_ai_messages_ai_sessions_ai_session_id",
                        column: x => x.ai_session_id,
                        principalTable: "ai_sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_messages_media_assets_audio_asset_id",
                        column: x => x.audio_asset_id,
                        principalTable: "media_assets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ai_usage_records",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_configuration_id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    ai_session_id = table.Column<Guid>(type: "uuid", nullable: true),
                    evaluation_request_id = table.Column<Guid>(type: "uuid", nullable: true),
                    provider_request_id = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    input_units = table.Column<long>(type: "bigint", nullable: false),
                    output_units = table.Column<long>(type: "bigint", nullable: false),
                    cost = table.Column<decimal>(type: "numeric(18,4)", precision: 18, scale: 4, nullable: false),
                    currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    recorded_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ai_usage_records", x => x.id);
                    table.CheckConstraint("ck_ai_usage_records_1", "input_units >= 0 AND output_units >= 0 AND cost >= 0");
                    table.CheckConstraint("ck_ai_usage_records_2", "currency ~ '^[A-Z]{3}$'");
                    table.ForeignKey(
                        name: "FK_ai_usage_records_ai_evaluation_requests_evaluation_request_~",
                        column: x => x.evaluation_request_id,
                        principalTable: "ai_evaluation_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_usage_records_ai_provider_configurations_provider_config~",
                        column: x => x.provider_configuration_id,
                        principalTable: "ai_provider_configurations",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_usage_records_ai_sessions_ai_session_id",
                        column: x => x.ai_session_id,
                        principalTable: "ai_sessions",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ai_usage_records_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "morphological_analyses",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    word_form_id = table.Column<Guid>(type: "uuid", nullable: false),
                    analyzer_version = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    features_schema_version = table.Column<int>(type: "integer", nullable: false),
                    features_json = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_morphological_analyses", x => x.id);
                    table.CheckConstraint("ck_morphological_analyses_1", "features_schema_version > 0");
                    table.ForeignKey(
                        name: "FK_morphological_analyses_word_forms_word_form_id",
                        column: x => x.word_form_id,
                        principalTable: "word_forms",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "word_examples",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    word_sense_id = table.Column<Guid>(type: "uuid", nullable: false),
                    text = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    source_attribution = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    video_id = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: true),
                    start_seconds = table.Column<int>(type: "integer", nullable: true),
                    end_seconds = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_word_examples", x => x.id);
                    table.CheckConstraint("ck_word_examples_1", "start_seconds IS NULL OR start_seconds >= 0");
                    table.CheckConstraint("ck_word_examples_2", "end_seconds IS NULL OR (start_seconds IS NOT NULL AND end_seconds > start_seconds)");
                    table.ForeignKey(
                        name: "FK_word_examples_word_senses_word_sense_id",
                        column: x => x.word_sense_id,
                        principalTable: "word_senses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "word_translations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    word_sense_id = table.Column<Guid>(type: "uuid", nullable: false),
                    target_language_id = table.Column<Guid>(type: "uuid", nullable: false),
                    text = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_word_translations", x => x.id);
                    table.ForeignKey(
                        name: "FK_word_translations_languages_target_language_id",
                        column: x => x.target_language_id,
                        principalTable: "languages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_word_translations_word_senses_word_sense_id",
                        column: x => x.word_sense_id,
                        principalTable: "word_senses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reading_vocabulary_references",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    reading_text_segment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    dictionary_entry_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_vocabulary_references", x => x.id);
                    table.ForeignKey(
                        name: "FK_reading_vocabulary_references_dictionary_entries_dictionary~",
                        column: x => x.dictionary_entry_id,
                        principalTable: "dictionary_entries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_vocabulary_references_reading_text_segments_reading~",
                        column: x => x.reading_text_segment_id,
                        principalTable: "reading_text_segments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_audio_asset_id",
                table: "ai_evaluation_requests",
                column: "audio_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_expires_at_utc",
                table: "ai_evaluation_requests",
                column: "expires_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_provider_configuration_id",
                table: "ai_evaluation_requests",
                column: "provider_configuration_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_scoring_rubric_id",
                table: "ai_evaluation_requests",
                column: "scoring_rubric_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_stage_attempt_id",
                table: "ai_evaluation_requests",
                column: "stage_attempt_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_requests_student_id_idempotency_key",
                table: "ai_evaluation_requests",
                columns: new[] { "student_id", "idempotency_key" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_results_ai_evaluation_request_id",
                table: "ai_evaluation_results",
                column: "ai_evaluation_request_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_evaluation_results_reviewed_by",
                table: "ai_evaluation_results",
                column: "reviewed_by");

            migrationBuilder.CreateIndex(
                name: "IX_ai_messages_ai_session_id_sequence",
                table: "ai_messages",
                columns: new[] { "ai_session_id", "sequence" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_messages_audio_asset_id",
                table: "ai_messages",
                column: "audio_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_processing_jobs_ai_evaluation_request_id",
                table: "ai_processing_jobs",
                column: "ai_evaluation_request_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_processing_jobs_status_available_at_utc",
                table: "ai_processing_jobs",
                columns: new[] { "status", "available_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_ai_provider_configurations_code_model_capability",
                table: "ai_provider_configurations",
                columns: new[] { "code", "model", "capability" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_sessions_expires_at_utc",
                table: "ai_sessions",
                column: "expires_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_ai_sessions_prompt_version_id",
                table: "ai_sessions",
                column: "prompt_version_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_sessions_provider_configuration_id",
                table: "ai_sessions",
                column: "provider_configuration_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_sessions_student_id_started_at_utc",
                table: "ai_sessions",
                columns: new[] { "student_id", "started_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_ai_tutor_prompt_versions_ai_tutor_id_version_number",
                table: "ai_tutor_prompt_versions",
                columns: new[] { "ai_tutor_id", "version_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_tutors_code",
                table: "ai_tutors",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_tutors_language_id",
                table: "ai_tutors",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_usage_records_ai_session_id",
                table: "ai_usage_records",
                column: "ai_session_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_usage_records_evaluation_request_id",
                table: "ai_usage_records",
                column: "evaluation_request_id");

            migrationBuilder.CreateIndex(
                name: "IX_ai_usage_records_provider_configuration_id_provider_request~",
                table: "ai_usage_records",
                columns: new[] { "provider_configuration_id", "provider_request_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ai_usage_records_recorded_at_utc",
                table: "ai_usage_records",
                column: "recorded_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_ai_usage_records_student_id",
                table: "ai_usage_records",
                column: "student_id");

            migrationBuilder.CreateIndex(
                name: "IX_dictionary_entries_language_id_lemma_part_of_speech",
                table: "dictionary_entries",
                columns: new[] { "language_id", "lemma", "part_of_speech" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_dictionary_entries_language_id_normalized_lemma",
                table: "dictionary_entries",
                columns: new[] { "language_id", "normalized_lemma" });

            migrationBuilder.CreateIndex(
                name: "IX_dictionary_entries_root_id",
                table: "dictionary_entries",
                column: "root_id");

            migrationBuilder.CreateIndex(
                name: "IX_dictionary_roots_language_id_letters",
                table: "dictionary_roots",
                columns: new[] { "language_id", "letters" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_morphological_analyses_word_form_id_analyzer_version",
                table: "morphological_analyses",
                columns: new[] { "word_form_id", "analyzer_version" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_pronunciations_dictionary_entry_id_media_asset_id",
                table: "pronunciations",
                columns: new[] { "dictionary_entry_id", "media_asset_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_pronunciations_media_asset_id",
                table: "pronunciations",
                column: "media_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_evaluations_ai_evaluation_request_id",
                table: "reading_evaluations",
                column: "ai_evaluation_request_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_evaluations_reading_session_id",
                table: "reading_evaluations",
                column: "reading_session_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_materials_language_id",
                table: "reading_materials",
                column: "language_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_materials_lesson_version_id",
                table: "reading_materials",
                column: "lesson_version_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_materials_pdf_asset_id",
                table: "reading_materials",
                column: "pdf_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_materials_uploaded_by",
                table: "reading_materials",
                column: "uploaded_by");

            migrationBuilder.CreateIndex(
                name: "IX_reading_passages_reading_material_id_sequence",
                table: "reading_passages",
                columns: new[] { "reading_material_id", "sequence" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_sessions_audio_asset_id",
                table: "reading_sessions",
                column: "audio_asset_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_sessions_expires_at_utc",
                table: "reading_sessions",
                column: "expires_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_reading_sessions_reading_material_id",
                table: "reading_sessions",
                column: "reading_material_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_sessions_student_id_started_at_utc",
                table: "reading_sessions",
                columns: new[] { "student_id", "started_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_reading_text_segments_reading_passage_id_sequence",
                table: "reading_text_segments",
                columns: new[] { "reading_passage_id", "sequence" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_vocabulary_references_dictionary_entry_id",
                table: "reading_vocabulary_references",
                column: "dictionary_entry_id");

            migrationBuilder.CreateIndex(
                name: "IX_reading_vocabulary_references_reading_text_segment_id_dicti~",
                table: "reading_vocabulary_references",
                columns: new[] { "reading_text_segment_id", "dictionary_entry_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_student_saved_words_dictionary_entry_id",
                table: "student_saved_words",
                column: "dictionary_entry_id");

            migrationBuilder.CreateIndex(
                name: "IX_student_saved_words_student_id_dictionary_entry_id",
                table: "student_saved_words",
                columns: new[] { "student_id", "dictionary_entry_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_translation_history_expires_at_utc",
                table: "translation_history",
                column: "expires_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_translation_history_source_language_id",
                table: "translation_history",
                column: "source_language_id");

            migrationBuilder.CreateIndex(
                name: "IX_translation_history_student_id_created_at_utc",
                table: "translation_history",
                columns: new[] { "student_id", "created_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_translation_history_target_language_id",
                table: "translation_history",
                column: "target_language_id");

            migrationBuilder.CreateIndex(
                name: "IX_word_examples_word_sense_id",
                table: "word_examples",
                column: "word_sense_id");

            migrationBuilder.CreateIndex(
                name: "IX_word_forms_dictionary_entry_id_text_form_type",
                table: "word_forms",
                columns: new[] { "dictionary_entry_id", "text", "form_type" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_word_forms_normalized_text",
                table: "word_forms",
                column: "normalized_text");

            migrationBuilder.CreateIndex(
                name: "IX_word_senses_dictionary_entry_id_sense_number",
                table: "word_senses",
                columns: new[] { "dictionary_entry_id", "sense_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_word_translations_target_language_id",
                table: "word_translations",
                column: "target_language_id");

            migrationBuilder.CreateIndex(
                name: "IX_word_translations_word_sense_id_target_language_id_text",
                table: "word_translations",
                columns: new[] { "word_sense_id", "target_language_id", "text" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ai_evaluation_results");

            migrationBuilder.DropTable(
                name: "ai_messages");

            migrationBuilder.DropTable(
                name: "ai_processing_jobs");

            migrationBuilder.DropTable(
                name: "ai_usage_records");

            migrationBuilder.DropTable(
                name: "morphological_analyses");

            migrationBuilder.DropTable(
                name: "pronunciations");

            migrationBuilder.DropTable(
                name: "reading_evaluations");

            migrationBuilder.DropTable(
                name: "reading_vocabulary_references");

            migrationBuilder.DropTable(
                name: "student_saved_words");

            migrationBuilder.DropTable(
                name: "translation_history");

            migrationBuilder.DropTable(
                name: "word_examples");

            migrationBuilder.DropTable(
                name: "word_translations");

            migrationBuilder.DropTable(
                name: "ai_sessions");

            migrationBuilder.DropTable(
                name: "word_forms");

            migrationBuilder.DropTable(
                name: "ai_evaluation_requests");

            migrationBuilder.DropTable(
                name: "reading_sessions");

            migrationBuilder.DropTable(
                name: "reading_text_segments");

            migrationBuilder.DropTable(
                name: "word_senses");

            migrationBuilder.DropTable(
                name: "ai_tutor_prompt_versions");

            migrationBuilder.DropTable(
                name: "ai_provider_configurations");

            migrationBuilder.DropTable(
                name: "reading_passages");

            migrationBuilder.DropTable(
                name: "dictionary_entries");

            migrationBuilder.DropTable(
                name: "ai_tutors");

            migrationBuilder.DropTable(
                name: "reading_materials");

            migrationBuilder.DropTable(
                name: "dictionary_roots");
        }
    }
}
