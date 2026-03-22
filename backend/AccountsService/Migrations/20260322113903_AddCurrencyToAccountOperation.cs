using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AccountsService.Migrations
{
    /// <inheritdoc />
    public partial class AddCurrencyToAccountOperation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Currency",
                table: "AccountOperations",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1"),
                column: "Currency",
                value: 0);

            migrationBuilder.UpdateData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2"),
                column: "Currency",
                value: 0);

            migrationBuilder.UpdateData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3"),
                column: "Currency",
                value: 0);

            migrationBuilder.UpdateData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4"),
                column: "Currency",
                value: 0);

            migrationBuilder.UpdateData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5"),
                column: "Currency",
                value: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Currency",
                table: "AccountOperations");
        }
    }
}
