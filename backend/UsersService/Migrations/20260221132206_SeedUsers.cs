using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace UsersService.Migrations
{
    /// <inheritdoc />
    public partial class SeedUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Birthday", "Created", "Email", "FirstName", "HashPassword", "IsBlocked", "LastName", "MiddleName", "Phone", "Role", "Updated" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new DateOnly(1990, 1, 1), new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "employee1@bank.ru", "Ivan", "hashed_password_1", false, "Petrov", "Ivanovich", "+79990000001", 1, null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new DateOnly(1992, 2, 2), new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "employee2@bank.ru", "Anna", "hashed_password_2", false, "Sidorova", "Petrovna", "+79990000002", 1, null },
                    { new Guid("33333333-3333-3333-3333-333333333333"), new DateOnly(1995, 3, 3), new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "client1@bank.ru", "Alexey", "hashed_password_3", false, "Smirnov", "Sergeevich", "+79990000003", 0, null },
                    { new Guid("44444444-4444-4444-4444-444444444444"), new DateOnly(1998, 4, 4), new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "client2@bank.ru", "Maria", "hashed_password_4", false, "Ivanova", "Alexandrovna", "+79990000004", 0, null },
                    { new Guid("55555555-5555-5555-5555-555555555555"), new DateOnly(2000, 5, 5), new DateTime(2026, 2, 21, 13, 22, 5, 987, DateTimeKind.Utc).AddTicks(7630), "client3@bank.ru", "Dmitry", "hashed_password_5", false, "Kozlov", "Igorevich", "+79990000005", 0, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"));
        }
    }
}
