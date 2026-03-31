using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UsersService.Migrations
{
    /// <inheritdoc />
    public partial class FixSeedPhones : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 31, 13, 7, 51, 650, DateTimeKind.Utc).AddTicks(3685), "$2a$11$M3yOiOGGChuRpPE8BnMviuI54I74PBxa7e57PZjrW6O1hAnw1qiDq", "79990000001" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 31, 13, 7, 51, 650, DateTimeKind.Utc).AddTicks(3685), "$2a$11$2oD/x22JojfWdXAUmezQh.rWp8D3xYXvgandm9H86ARgu/Rt2nEd6", "79990000002" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 31, 13, 7, 51, 650, DateTimeKind.Utc).AddTicks(3685), "$2a$11$kAUnI0TtXQ5aJmBLt1rT2eYVGpmhy6AvgnkJUWr7hKwMXbLVudDh6", "79990000003" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 31, 13, 7, 51, 650, DateTimeKind.Utc).AddTicks(3685), "$2a$11$jN2Bw5tw/rS.AAr0rNwkhetXUACEmr8KkFzhs1MKzQ/MtymOgslUu", "79990000004" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 31, 13, 7, 51, 650, DateTimeKind.Utc).AddTicks(3685), "$2a$11$.RwnB7/p/IAhZ4jb8Al0GOyPBxnzCuoc76ugO8nqmU5jzwEq/IaxW", "79990000005" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$oU5DTA7UcGCJxNmFepQt8etbTxRMdZXX5ajmLGD0PM5F8pUTq5Yly", "+79990000001" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$GZdB1Gx1merUmnI82ifjiu7w95Xdy//06rJl73KTix4.aMQSCMUEy", "+79990000002" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$HNQvGdlxBlOZoTtvD3Ln5unVOJJGVDYLGBgB648beyQOzbHOC9VW2", "+79990000003" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$1RgkChsUf2aLuBkP4JuaUOJsXFdHuC1jEnAvOTN.8tHYQb7J501Nu", "+79990000004" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword", "Phone" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$dZf6ypgxl94zyrVftomd3OZdkOzm4CzyWJssiUrInBFUfib4Kbl8S", "+79990000005" });
        }
    }
}
