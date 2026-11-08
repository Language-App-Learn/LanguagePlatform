using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddFiveStageCurriculum : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "curriculum_level_id",
                table: "lessons",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "curriculum_position",
                table: "lessons",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "uses_five_stage_curriculum",
                table: "lesson_versions",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "weights_approved",
                table: "lesson_versions",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "uses_five_stage_curriculum",
                table: "courses",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_lessons_curriculum_level_id_curriculum_position",
                table: "lessons",
                columns: new[] { "curriculum_level_id", "curriculum_position" },
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "ck_lessons_curriculum_slot",
                table: "lessons",
                sql: "(curriculum_level_id IS NULL AND curriculum_position IS NULL) OR (curriculum_level_id IS NOT NULL AND curriculum_position IS NOT NULL AND curriculum_position BETWEEN 1 AND 20)");

            migrationBuilder.AddCheckConstraint(
                name: "ck_lesson_versions_five_stage",
                table: "lesson_versions",
                sql: "NOT uses_five_stage_curriculum OR (passing_score = 60 AND (status <> 'Published' OR weights_approved))");

            migrationBuilder.AddForeignKey(
                name: "FK_lessons_course_levels_curriculum_level_id",
                table: "lessons",
                column: "curriculum_level_id",
                principalTable: "course_levels",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_lessons_course_levels_curriculum_level_id",
                table: "lessons");

            migrationBuilder.DropIndex(
                name: "IX_lessons_curriculum_level_id_curriculum_position",
                table: "lessons");

            migrationBuilder.DropCheckConstraint(
                name: "ck_lessons_curriculum_slot",
                table: "lessons");

            migrationBuilder.DropCheckConstraint(
                name: "ck_lesson_versions_five_stage",
                table: "lesson_versions");

            migrationBuilder.DropColumn(
                name: "curriculum_level_id",
                table: "lessons");

            migrationBuilder.DropColumn(
                name: "curriculum_position",
                table: "lessons");

            migrationBuilder.DropColumn(
                name: "uses_five_stage_curriculum",
                table: "lesson_versions");

            migrationBuilder.DropColumn(
                name: "weights_approved",
                table: "lesson_versions");

            migrationBuilder.DropColumn(
                name: "uses_five_stage_curriculum",
                table: "courses");
        }
    }
}
