using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddObjectiveAssessmentAndFavorites : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_favorite",
                table: "student_saved_words",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "deadline_utc",
                table: "assessment_attempts",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "passing_score_snapshot",
                table: "assessment_attempts",
                type: "numeric(18,4)",
                precision: 18,
                scale: 4,
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "ck_assessment_attempts_policy",
                table: "assessment_attempts",
                sql: "(passing_score_snapshot IS NULL OR passing_score_snapshot BETWEEN 0 AND 100) AND (deadline_utc IS NULL OR deadline_utc > started_at_utc)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_assessment_attempts_policy",
                table: "assessment_attempts");

            migrationBuilder.DropColumn(
                name: "is_favorite",
                table: "student_saved_words");

            migrationBuilder.DropColumn(
                name: "deadline_utc",
                table: "assessment_attempts");

            migrationBuilder.DropColumn(
                name: "passing_score_snapshot",
                table: "assessment_attempts");
        }
    }
}
