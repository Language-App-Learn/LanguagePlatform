using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguagePlatform.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddLearningPathPreference : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "learning_path_id",
                table: "user_preferences",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<uint>(
                name: "xmin",
                table: "user_preferences",
                type: "xid",
                rowVersion: true,
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.CreateIndex(
                name: "IX_user_preferences_learning_path_id",
                table: "user_preferences",
                column: "learning_path_id");

            migrationBuilder.AddForeignKey(
                name: "FK_user_preferences_learning_paths_learning_path_id",
                table: "user_preferences",
                column: "learning_path_id",
                principalTable: "learning_paths",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_user_preferences_learning_paths_learning_path_id",
                table: "user_preferences");

            migrationBuilder.DropIndex(
                name: "IX_user_preferences_learning_path_id",
                table: "user_preferences");

            migrationBuilder.DropColumn(
                name: "learning_path_id",
                table: "user_preferences");

            migrationBuilder.DropColumn(
                name: "xmin",
                table: "user_preferences");
        }
    }
}
