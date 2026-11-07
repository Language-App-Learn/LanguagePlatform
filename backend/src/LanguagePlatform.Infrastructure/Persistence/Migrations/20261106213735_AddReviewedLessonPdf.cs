using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddReviewedLessonPdf : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "extracted_pages_json",
                table: "reading_materials",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "original_pdf",
                table: "reading_materials",
                type: "bytea",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "reviewed_at_utc",
                table: "reading_materials",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "reading_material_revision",
                table: "lesson_versions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "UX_reading_materials_inline_pdf_version",
                table: "reading_materials",
                column: "lesson_version_id",
                unique: true,
                filter: "original_pdf IS NOT NULL");

            migrationBuilder.AddCheckConstraint(
                name: "ck_reading_materials_inline_pdf",
                table: "reading_materials",
                sql: "original_pdf IS NULL OR (octet_length(original_pdf) BETWEEN 8 AND 2097152 AND extracted_pages_json IS NOT NULL)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UX_reading_materials_inline_pdf_version",
                table: "reading_materials");

            migrationBuilder.DropCheckConstraint(
                name: "ck_reading_materials_inline_pdf",
                table: "reading_materials");

            migrationBuilder.DropColumn(
                name: "extracted_pages_json",
                table: "reading_materials");

            migrationBuilder.DropColumn(
                name: "original_pdf",
                table: "reading_materials");

            migrationBuilder.DropColumn(
                name: "reviewed_at_utc",
                table: "reading_materials");

            migrationBuilder.DropColumn(
                name: "reading_material_revision",
                table: "lesson_versions");
        }
    }
}
