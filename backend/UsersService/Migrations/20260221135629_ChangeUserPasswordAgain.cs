using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UsersService.Migrations
{
    /// <inheritdoc />
    public partial class ChangeUserPasswordAgain : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 56, 28, 195, DateTimeKind.Utc).AddTicks(3630), "$2a$11$7kQQnzeF8i3FK9skkL63EukwpUTJhjvjZEJN1lhdO.HvKlG0MYVRe" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 56, 28, 195, DateTimeKind.Utc).AddTicks(3630), "$2a$11$eLSrQwC8hMy7V8cvSrYDlO5vc/Hp2Vhye9NEqHCS6geDMTtEeKieG" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 56, 28, 195, DateTimeKind.Utc).AddTicks(3630), "$2a$11$7I03XrfM/igfvh7gANkaVu/zKAXXMwHJtAo2s4ouAtGOpwCJSNhA6" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 56, 28, 195, DateTimeKind.Utc).AddTicks(3630), "$2a$11$cmgQfMCkY542OvrsAT0IFu86NWTvE8WKnz4ABCMuh75WfwAvVr0vO" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 2, 21, 13, 56, 28, 195, DateTimeKind.Utc).AddTicks(3630), "$2a$11$Pq2G5IuLpabl.IAsrPwwmu1g0cmEr5V1tAsJ6JpKnbSY4MbEYsvFi" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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
    }
}
