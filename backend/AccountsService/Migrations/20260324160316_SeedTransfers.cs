using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AccountsService.Migrations
{
    /// <inheritdoc />
    public partial class SeedTransfers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "AccountOperations",
                columns: new[] { "Id", "AccountId", "Amount", "CreatedAt", "Currency", "Type" },
                values: new object[,]
                {
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000010"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6"), 7000m, new DateTime(2024, 3, 20, 0, 0, 0, 0, DateTimeKind.Utc), 0, 3 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000011"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1"), 7000m, new DateTime(2024, 3, 20, 0, 0, 0, 0, DateTimeKind.Utc), 0, 2 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000012"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1"), 3000m, new DateTime(2024, 3, 22, 0, 0, 0, 0, DateTimeKind.Utc), 0, 3 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000013"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3"), 3000m, new DateTime(2024, 3, 22, 0, 0, 0, 0, DateTimeKind.Utc), 0, 2 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000014"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5"), 2000m, new DateTime(2024, 3, 25, 0, 0, 0, 0, DateTimeKind.Utc), 1, 3 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000015"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3"), 2000m, new DateTime(2024, 3, 25, 0, 0, 0, 0, DateTimeKind.Utc), 0, 2 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3"), 10000m, new DateTime(2024, 3, 15, 0, 0, 0, 0, DateTimeKind.Utc), 0, 3 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4"), 10000m, new DateTime(2024, 3, 15, 0, 0, 0, 0, DateTimeKind.Utc), 1, 2 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb8"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4"), 5000m, new DateTime(2024, 3, 18, 0, 0, 0, 0, DateTimeKind.Utc), 1, 3 },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb9"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5"), 5000m, new DateTime(2024, 3, 18, 0, 0, 0, 0, DateTimeKind.Utc), 1, 2 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000010"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000011"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000012"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000013"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000014"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-000000000015"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb8"));

            migrationBuilder.DeleteData(
                table: "AccountOperations",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb9"));
        }
    }
}
