using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CreditsService.Migrations
{
    /// <inheritdoc />
    public partial class SeedCredits : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Tariffs",
                columns: new[] { "Id", "CreatedAt", "InterestRate", "IsActive", "Name" },
                values: new object[,]
                {
                    { new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), 0.1490m, true, "Стандарт" },
                    { new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"), new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), 0.2190m, true, "Гибкий" },
                    { new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"), new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 0.0990m, true, "Премиум" }
                });

            migrationBuilder.InsertData(
                table: "Loans",
                columns: new[] { "Id", "CreatedAt", "InitialAmount", "IsActive", "LastInterestApplicationDate", "RemainingAmount", "TariffId", "UserId" },
                values: new object[,]
                {
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddd10"), new DateTime(2024, 7, 7, 0, 0, 0, 0, DateTimeKind.Utc), 100000m, true, new DateTime(2024, 7, 7, 0, 0, 0, 0, DateTimeKind.Utc), 85000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"), new Guid("44444444-4444-4444-4444-444444444444") },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddd11"), new DateTime(2024, 2, 2, 0, 0, 0, 0, DateTimeKind.Utc), 220000m, true, new DateTime(2024, 2, 2, 0, 0, 0, 0, DateTimeKind.Utc), 190000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddd12"), new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Utc), 70000m, true, new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Utc), 52000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddd13"), new DateTime(2024, 8, 15, 0, 0, 0, 0, DateTimeKind.Utc), 130000m, true, new DateTime(2024, 8, 15, 0, 0, 0, 0, DateTimeKind.Utc), 100000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd1"), new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), 120000m, true, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), 90000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new Guid("11111111-1111-1111-1111-111111111111") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd2"), new DateTime(2024, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), 300000m, true, new DateTime(2024, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), 240000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"), new Guid("11111111-1111-1111-1111-111111111111") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd3"), new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), 80000m, true, new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), 65000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"), new Guid("22222222-2222-2222-2222-222222222222") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd4"), new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), 200000m, true, new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), 175000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new Guid("22222222-2222-2222-2222-222222222222") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd5"), new DateTime(2024, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 150000m, true, new DateTime(2024, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 110000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"), new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd6"), new DateTime(2024, 2, 25, 0, 0, 0, 0, DateTimeKind.Utc), 50000m, true, new DateTime(2024, 2, 25, 0, 0, 0, 0, DateTimeKind.Utc), 38000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd7"), new DateTime(2024, 5, 10, 0, 0, 0, 0, DateTimeKind.Utc), 90000m, true, new DateTime(2024, 5, 10, 0, 0, 0, 0, DateTimeKind.Utc), 72000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"), new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd8"), new DateTime(2024, 3, 12, 0, 0, 0, 0, DateTimeKind.Utc), 60000m, true, new DateTime(2024, 3, 12, 0, 0, 0, 0, DateTimeKind.Utc), 45000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"), new Guid("44444444-4444-4444-4444-444444444444") },
                    { new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd9"), new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Utc), 400000m, true, new DateTime(2024, 6, 1, 0, 0, 0, 0, DateTimeKind.Utc), 340000m, new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"), new Guid("44444444-4444-4444-4444-444444444444") }
                });

            migrationBuilder.InsertData(
                table: "LoanOperations",
                columns: new[] { "Id", "Amount", "LoanId", "OperationDate", "Type" },
                values: new object[,]
                {
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee10"), 12000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd6"), new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee11"), 8000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd7"), new DateTime(2024, 5, 25, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee12"), 10000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd7"), new DateTime(2024, 6, 10, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee13"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd8"), new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee14"), 30000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd9"), new DateTime(2024, 6, 20, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee15"), 30000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd9"), new DateTime(2024, 7, 20, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee16"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd10"), new DateTime(2024, 8, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee17"), 10000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd11"), new DateTime(2024, 2, 20, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee18"), 20000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd11"), new DateTime(2024, 3, 20, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee19"), 8000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd12"), new DateTime(2024, 5, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee20"), 10000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd12"), new DateTime(2024, 5, 25, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee21"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd13"), new DateTime(2024, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee22"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-dddddddddd13"), new DateTime(2024, 10, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1"), 10000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd1"), new DateTime(2024, 2, 15, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2"), 20000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd1"), new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3"), 25000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd2"), new DateTime(2024, 3, 20, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4"), 35000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd2"), new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd3"), new DateTime(2024, 3, 3, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee6"), 10000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd4"), new DateTime(2024, 4, 15, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee7"), 15000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd4"), new DateTime(2024, 5, 5, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee8"), 20000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd5"), new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee9"), 20000m, new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd5"), new DateTime(2024, 3, 10, 0, 0, 0, 0, DateTimeKind.Utc), 2 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee10"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee11"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee12"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee13"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee14"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee15"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee16"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee17"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee18"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee19"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee20"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee21"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee22"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee6"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee7"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee8"));

            migrationBuilder.DeleteData(
                table: "LoanOperations",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee9"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddd10"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddd11"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddd12"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddd13"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd1"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd2"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd3"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd4"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd5"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd6"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd7"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd8"));

            migrationBuilder.DeleteData(
                table: "Loans",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-ddddddddddd9"));

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc1"));

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc2"));

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-ccccccccccc3"));
        }
    }
}
