using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UsersService.Migrations
{
    /// <inheritdoc />
    public partial class AddUniquePhone : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BlackTokens");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$oU5DTA7UcGCJxNmFepQt8etbTxRMdZXX5ajmLGD0PM5F8pUTq5Yly" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$GZdB1Gx1merUmnI82ifjiu7w95Xdy//06rJl73KTix4.aMQSCMUEy" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$HNQvGdlxBlOZoTtvD3Ln5unVOJJGVDYLGBgB648beyQOzbHOC9VW2" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$1RgkChsUf2aLuBkP4JuaUOJsXFdHuC1jEnAvOTN.8tHYQb7J501Nu" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "Created", "HashPassword" },
                values: new object[] { new DateTime(2026, 3, 22, 9, 23, 1, 308, DateTimeKind.Utc).AddTicks(8707), "$2a$11$dZf6ypgxl94zyrVftomd3OZdkOzm4CzyWJssiUrInBFUfib4Kbl8S" });

            migrationBuilder.CreateIndex(
                name: "IX_Users_Phone",
                table: "Users",
                column: "Phone",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_Phone",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "BlackTokens",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ExpiredAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Token = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlackTokens", x => x.Id);
                });

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
    }
}
