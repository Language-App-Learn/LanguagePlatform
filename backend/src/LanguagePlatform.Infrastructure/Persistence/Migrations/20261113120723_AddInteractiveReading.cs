using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddInteractiveReading : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "reference_audio",
                table: "reading_text_segments",
                type: "bytea",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "reading_line_attempts",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    student_id = table.Column<Guid>(type: "uuid", nullable: false),
                    segment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    idempotency_key = table.Column<Guid>(type: "uuid", nullable: false),
                    recording_digest = table.Column<byte[]>(type: "bytea", nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    deadline_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    reason = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_line_attempts", x => x.id);
                    table.CheckConstraint("ck_reading_line_attempts_deadline", "deadline_utc > created_at_utc");
                    table.CheckConstraint("ck_reading_line_attempts_digest", "octet_length(recording_digest) = 32");
                    table.CheckConstraint("ck_reading_line_attempts_status", "(status IN ('Pending', 'Approved') AND reason IS NULL) OR (status IN ('RetryRequired', 'Inconclusive', 'TechnicalError') AND reason IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_reading_line_attempts_identity_users_student_id",
                        column: x => x.student_id,
                        principalTable: "identity_users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_reading_line_attempts_reading_text_segments_segment_id",
                        column: x => x.segment_id,
                        principalTable: "reading_text_segments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.AddCheckConstraint(
                name: "ck_reading_text_segments_reference_audio",
                table: "reading_text_segments",
                sql: "reference_audio IS NULL OR octet_length(reference_audio) BETWEEN 8044 AND 640044");

            migrationBuilder.CreateIndex(
                name: "IX_reading_line_attempts_segment_id",
                table: "reading_line_attempts",
                column: "segment_id");

            migrationBuilder.CreateIndex(
                name: "ux_reading_line_attempts_active_line",
                table: "reading_line_attempts",
                columns: new[] { "student_id", "segment_id" },
                unique: true,
                filter: "status IN ('Pending', 'Approved')");

            migrationBuilder.CreateIndex(
                name: "ux_reading_line_attempts_idempotency",
                table: "reading_line_attempts",
                columns: new[] { "student_id", "idempotency_key" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "reading_line_attempts");

            migrationBuilder.DropCheckConstraint(
                name: "ck_reading_text_segments_reference_audio",
                table: "reading_text_segments");

            migrationBuilder.DropColumn(
                name: "reference_audio",
                table: "reading_text_segments");
        }
    }
}
