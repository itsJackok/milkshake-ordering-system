using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MilkshakeAPI.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedData_20251130 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "Description", "Name", "Price", "Type" },
                values: new object[] { "No extra topping", "No Topping", 0.00m, "Topping" });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Extra thick consistency", "Double Thick", 5.00m });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Thick consistency", "Thick", 3.00m });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Regular milky consistency", "Milky", 0.00m });

            migrationBuilder.InsertData(
                table: "Lookups",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "LastAction", "LastUpdated", "LastUpdatedBy", "Name", "Price", "Type" },
                values: new object[] { 18, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Icy slushy consistency", true, null, null, null, "Icy", 2.00m, "Consistency" });

            migrationBuilder.InsertData(
                table: "Restaurants",
                columns: new[] { "Id", "Address", "ClosingTime", "CreatedAt", "IsActive", "LastUpdated", "LastUpdatedBy", "Name", "OpeningTime", "PhoneNumber" },
                values: new object[,]
                {
                    { 4, "Fourways Mall, William Nicol Drive, Fourways, 2191", new TimeSpan(0, 21, 30, 0, 0), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, null, null, "Milky Shaky Fourways", new TimeSpan(0, 8, 30, 0, 0), "011-789-3344" },
                    { 5, "Mall of Africa, Magwa Crescent, Midrand, 1685", new TimeSpan(0, 22, 0, 0, 0), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, null, null, "Milky Shaky Midrand", new TimeSpan(0, 9, 0, 0, 0), "012-456-7789" },
                    { 6, "Centurion Mall, Heuwel Avenue, Centurion, 0157", new TimeSpan(0, 20, 0, 0, 0), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, null, null, "Milky Shaky Centurion", new TimeSpan(0, 8, 0, 0, 0), "012-665-4422" },
                    { 7, "Gateway Theatre of Shopping, Umhlanga, 4319", new TimeSpan(0, 21, 30, 0, 0), new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, null, null, "Milky Shaky Durban", new TimeSpan(0, 9, 0, 0, 0), "031-555-1234" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Restaurants",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Restaurants",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Restaurants",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Restaurants",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "Description", "Name", "Price", "Type" },
                values: new object[] { "Extra thick consistency", "Double Thick", 5.00m, "Consistency" });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Thick consistency", "Thick", 3.00m });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Regular milky consistency", "Milky", 0.00m });

            migrationBuilder.UpdateData(
                table: "Lookups",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "Description", "Name", "Price" },
                values: new object[] { "Icy slushy consistency", "Icy", 2.00m });
        }
    }
}
