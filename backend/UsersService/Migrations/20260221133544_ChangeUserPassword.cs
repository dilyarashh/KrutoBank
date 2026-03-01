using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UsersService.Migrations
{
    /// <inheritdoc />
    public partial class ChangeUserPassword : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 35, 43, 837, DateTimeKind.Utc).AddTicks(6160), "12345678" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 35, 43, 837, DateTimeKind.Utc).AddTicks(6160), "12345678" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 35, 43, 837, DateTimeKind.Utc).AddTicks(6160), "12345678" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 35, 43, 837, DateTimeKind.Utc).AddTicks(6160), "12345678" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 35, 43, 837, DateTimeKind.Utc).AddTicks(6160), "12345678" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "hashed_password_1" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "hashed_password_2" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "hashed_password_3" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "hashed_password_4" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "hashed_password_5" });
        }
    }
}
