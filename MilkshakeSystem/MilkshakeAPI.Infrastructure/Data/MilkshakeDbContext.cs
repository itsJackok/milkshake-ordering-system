using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MilkshakeAPI.Domain.Entities;

namespace MilkshakeAPI.Infrastructure.Data
{
	public class MilkshakeDbContext : DbContext
	{
		public MilkshakeDbContext(DbContextOptions<MilkshakeDbContext> options)
			: base(options)
		{
		}

		public DbSet<User> Users { get; set; }
		public DbSet<Restaurant> Restaurants { get; set; }
		public DbSet<Order> Orders { get; set; }
		public DbSet<OrderItem> OrderItems { get; set; }
		public DbSet<Lookup> Lookups { get; set; }
		public DbSet<DiscountTier> DiscountTiers { get; set; }
		public DbSet<Configuration> Configurations { get; set; }
		public DbSet<AuditLog> AuditLogs { get; set; }
		public DbSet<Payment> Payments { get; set; }
		public DbSet<EmailLog> EmailLogs { get; set; }

		protected override void OnModelCreating(ModelBuilder modelBuilder)
		{
			base.OnModelCreating(modelBuilder);

			// Configure relationships
			ConfigureRelationships(modelBuilder);

			// Seed initial data
			SeedData(modelBuilder);
		}

		private void ConfigureRelationships(ModelBuilder modelBuilder)
		{
			// User -> Orders (One-to-Many)
			modelBuilder.Entity<Order>()
				.HasOne(o => o.User)
				.WithMany(u => u.Orders)
				.HasForeignKey(o => o.UserId)
				.OnDelete(DeleteBehavior.Restrict);

			// Restaurant -> Orders (One-to-Many)
			modelBuilder.Entity<Order>()
				.HasOne(o => o.Restaurant)
				.WithMany(r => r.Orders)
				.HasForeignKey(o => o.RestaurantId)
				.OnDelete(DeleteBehavior.Restrict);

			// Order -> OrderItems (One-to-Many)
			modelBuilder.Entity<OrderItem>()
				.HasOne(oi => oi.Order)
				.WithMany(o => o.OrderItems)
				.HasForeignKey(oi => oi.OrderId)
				.OnDelete(DeleteBehavior.Cascade);

			// Lookup -> OrderItem (Flavour)
			modelBuilder.Entity<OrderItem>()
				.HasOne(oi => oi.Flavour)
				.WithMany()
				.HasForeignKey(oi => oi.FlavourId)
				.OnDelete(DeleteBehavior.Restrict);

			// Lookup -> OrderItem (Topping)
			modelBuilder.Entity<OrderItem>()
				.HasOne(oi => oi.Topping)
				.WithMany()
				.HasForeignKey(oi => oi.ToppingId)
				.OnDelete(DeleteBehavior.Restrict);

			// Lookup -> OrderItem (Consistency)
			modelBuilder.Entity<OrderItem>()
				.HasOne(oi => oi.Consistency)
				.WithMany()
				.HasForeignKey(oi => oi.ConsistencyId)
				.OnDelete(DeleteBehavior.Restrict);

			// Order -> Payment (One-to-One)
			modelBuilder.Entity<Payment>()
				.HasOne(p => p.Order)
				.WithOne(o => o.Payment)
				.HasForeignKey<Payment>(p => p.OrderId)
				.OnDelete(DeleteBehavior.Cascade);

			// User -> AuditLogs (One-to-Many)
			modelBuilder.Entity<AuditLog>()
				.HasOne(a => a.User)
				.WithMany(u => u.AuditLogs)
				.HasForeignKey(a => a.UserId)
				.OnDelete(DeleteBehavior.Restrict);

			// User -> EmailLogs (One-to-Many)
			modelBuilder.Entity<EmailLog>()
				.HasOne(e => e.User)
				.WithMany()
				.HasForeignKey(e => e.UserId)
				.OnDelete(DeleteBehavior.Restrict);

			// Order -> EmailLogs (One-to-Many)
			modelBuilder.Entity<EmailLog>()
				.HasOne(e => e.Order)
				.WithMany(o => o.EmailLogs)
				.HasForeignKey(e => e.OrderId)
				.OnDelete(DeleteBehavior.Restrict);

			// Configure decimal precision
			modelBuilder.Entity<Order>()
				.Property(o => o.Subtotal).HasPrecision(10, 2);
			modelBuilder.Entity<Order>()
				.Property(o => o.VAT).HasPrecision(10, 2);
			modelBuilder.Entity<Order>()
				.Property(o => o.DiscountAmount).HasPrecision(10, 2);
			modelBuilder.Entity<Order>()
				.Property(o => o.TotalCost).HasPrecision(10, 2);

			modelBuilder.Entity<OrderItem>()
				.Property(oi => oi.FlavourPrice).HasPrecision(10, 2);
			modelBuilder.Entity<OrderItem>()
				.Property(oi => oi.ToppingPrice).HasPrecision(10, 2);
			modelBuilder.Entity<OrderItem>()
				.Property(oi => oi.ConsistencyPrice).HasPrecision(10, 2);
			modelBuilder.Entity<OrderItem>()
				.Property(oi => oi.ItemTotal).HasPrecision(10, 2);

			modelBuilder.Entity<Lookup>()
				.Property(l => l.Price).HasPrecision(10, 2);

			modelBuilder.Entity<DiscountTier>()
				.Property(dt => dt.DiscountPercentage).HasPrecision(5, 2);
			modelBuilder.Entity<DiscountTier>()
				.Property(dt => dt.MaxDiscountAmount).HasPrecision(10, 2);

			modelBuilder.Entity<Payment>()
				.Property(p => p.Amount).HasPrecision(10, 2);
		}

		private void SeedData(ModelBuilder modelBuilder)
		{
			var now = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

			// Seed Flavours (as per requirement document)
			modelBuilder.Entity<Lookup>().HasData(
				new Lookup { Id = 1, Name = "Strawberry", Type = "Flavour", Price = 40.00m, Description = "Fresh strawberry milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 2, Name = "Vanilla", Type = "Flavour", Price = 35.00m, Description = "Classic vanilla milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 3, Name = "Chocolate", Type = "Flavour", Price = 42.00m, Description = "Rich chocolate milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 4, Name = "Coffee", Type = "Flavour", Price = 45.00m, Description = "Coffee-flavored milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 5, Name = "Banana", Type = "Flavour", Price = 38.00m, Description = "Banana milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 6, Name = "Oreo", Type = "Flavour", Price = 48.00m, Description = "Oreo cookie milkshake", CreatedAt = now, IsActive = true },
				new Lookup { Id = 7, Name = "Bar One", Type = "Flavour", Price = 50.00m, Description = "Bar One chocolate milkshake", CreatedAt = now, IsActive = true }
			);

			// Seed Toppings (as per requirement document)
			modelBuilder.Entity<Lookup>().HasData(
				new Lookup { Id = 8, Name = "Frozen Strawberries", Type = "Topping", Price = 10.00m, Description = "Fresh frozen strawberry pieces", CreatedAt = now, IsActive = true },
				new Lookup { Id = 9, Name = "Freeze-dried Banana", Type = "Topping", Price = 12.00m, Description = "Freeze-dried banana slices", CreatedAt = now, IsActive = true },
				new Lookup { Id = 10, Name = "Oreo Crumbs", Type = "Topping", Price = 8.00m, Description = "Crushed Oreo cookies", CreatedAt = now, IsActive = true },
				new Lookup { Id = 11, Name = "Bar One Syrup", Type = "Topping", Price = 10.00m, Description = "Bar One chocolate syrup", CreatedAt = now, IsActive = true },
				new Lookup { Id = 12, Name = "Coffee Powder with Chocolate", Type = "Topping", Price = 15.00m, Description = "Coffee and chocolate mix", CreatedAt = now, IsActive = true },
				new Lookup { Id = 13, Name = "Chocolate Vermicelli", Type = "Topping", Price = 8.00m, Description = "Chocolate sprinkles", CreatedAt = now, IsActive = true },
				new Lookup { Id = 14, Name = "No Topping", Type = "Topping", Price = 0.00m, Description = "No extra topping", CreatedAt = now, IsActive = true }
			);

			// Seed Consistencies (as per requirement document)
			modelBuilder.Entity<Lookup>().HasData(
				new Lookup { Id = 15, Name = "Double Thick", Type = "Consistency", Price = 5.00m, Description = "Extra thick consistency", CreatedAt = now, IsActive = true },
				new Lookup { Id = 16, Name = "Thick", Type = "Consistency", Price = 3.00m, Description = "Thick consistency", CreatedAt = now, IsActive = true },
				new Lookup { Id = 17, Name = "Milky", Type = "Consistency", Price = 0.00m, Description = "Regular milky consistency", CreatedAt = now, IsActive = true },
				new Lookup { Id = 18, Name = "Icy", Type = "Consistency", Price = 2.00m, Description = "Icy slushy consistency", CreatedAt = now, IsActive = true }
			);

			// Seed Discount Tiers (3-tier system)
			modelBuilder.Entity<DiscountTier>().HasData(
				new DiscountTier
				{
					Id = 1,
					TierLevel = 1,
					TierName = "Bronze",
					MinimumOrders = 5,
					MinimumDrinksPerOrder = 2,
					DiscountPercentage = 5.00m,
					MaxDiscountAmount = 50.00m,
					Description = "5% discount for frequent customers",
					IsActive = true,
					CreatedAt = now
				},
				new DiscountTier
				{
					Id = 2,
					TierLevel = 2,
					TierName = "Silver",
					MinimumOrders = 10,
					MinimumDrinksPerOrder = 3,
					DiscountPercentage = 10.00m,
					MaxDiscountAmount = 100.00m,
					Description = "10% discount for loyal customers",
					IsActive = true,
					CreatedAt = now
				},
				new DiscountTier
				{
					Id = 3,
					TierLevel = 3,
					TierName = "Gold",
					MinimumOrders = 20,
					MinimumDrinksPerOrder = 5,
					DiscountPercentage = 15.00m,
					MaxDiscountAmount = 200.00m,
					Description = "15% discount for VIP customers",
					IsActive = true,
					CreatedAt = now
				}
			);

			// Seed Configurations
			modelBuilder.Entity<Configuration>().HasData(
				new Configuration
				{
					Id = 1,
					Key = "MinDrinks",
					Value = "1",
					Description = "Minimum number of drinks per order",
					DataType = "Integer",
					CreatedAt = now
				},
				new Configuration
				{
					Id = 2,
					Key = "MaxDrinks",
					Value = "10",
					Description = "Maximum number of drinks per order",
					DataType = "Integer",
					CreatedAt = now
				},
				new Configuration
				{
					Id = 3,
					Key = "VATPercentage",
					Value = "15",
					Description = "VAT percentage to apply to orders",
					DataType = "Decimal",
					CreatedAt = now
				},
				new Configuration
				{
					Id = 4,
					Key = "PreparationTime",
					Value = "15",
					Description = "Average preparation time in minutes",
					DataType = "Integer",
					CreatedAt = now
				}
			);

			// Seed Restaurants
			modelBuilder.Entity<Restaurant>().HasData(
				new Restaurant
				{
					Id = 1,
					Name = "Milky Shaky Pretoria",
					Address = "36 Maponya Street, Pretoria CBD, 0002",
					PhoneNumber = "012-345-6789",
					OpeningTime = new TimeSpan(8, 0, 0),
					ClosingTime = new TimeSpan(20, 0, 0),
					IsActive = true,
					CreatedAt = now
				},
				new Restaurant
				{
					Id = 2,
					Name = "Milky Shaky Sandton",
					Address = "Nelson Mandela Square, Sandton, 2196",
					PhoneNumber = "011-234-5678",
					OpeningTime = new TimeSpan(9, 0, 0),
					ClosingTime = new TimeSpan(21, 0, 0),
					IsActive = true,
					CreatedAt = now
				},
				new Restaurant
				{
					Id = 3,
					Name = "Milky Shaky Cape Town",
					Address = "V&A Waterfront, Cape Town, 8002",
					PhoneNumber = "021-456-7890",
					OpeningTime = new TimeSpan(8, 30, 0),
					ClosingTime = new TimeSpan(22, 0, 0),
					IsActive = true,
					CreatedAt = now
				},
                new Restaurant
                {
                    Id = 4,
                    Name = "Milky Shaky Fourways",
                    Address = "Fourways Mall, William Nicol Drive, Fourways, 2191",
                    PhoneNumber = "011-789-3344",
                    OpeningTime = new TimeSpan(8, 30, 0),
                    ClosingTime = new TimeSpan(21, 30, 0),
                    IsActive = true,
                    CreatedAt = now
                },
				new Restaurant
				{
					Id = 5,
					Name = "Milky Shaky Midrand",
					Address = "Mall of Africa, Magwa Crescent, Midrand, 1685",
					PhoneNumber = "012-456-7789",
					OpeningTime = new TimeSpan(9, 0, 0),
					ClosingTime = new TimeSpan(22, 0, 0),
					IsActive = true,
					CreatedAt = now
				},
				new Restaurant
				{
					Id = 6,
					Name = "Milky Shaky Centurion",
					Address = "Centurion Mall, Heuwel Avenue, Centurion, 0157",
					PhoneNumber = "012-665-4422",
					OpeningTime = new TimeSpan(8, 0, 0),
					ClosingTime = new TimeSpan(20, 0, 0),
					IsActive = true,
					CreatedAt = now
				},
                new Restaurant
                {
                    Id = 7,
                    Name = "Milky Shaky Durban",
                    Address = "Gateway Theatre of Shopping, Umhlanga, 4319",
                    PhoneNumber = "031-555-1234",
                    OpeningTime = new TimeSpan(9, 0, 0),
                    ClosingTime = new TimeSpan(21, 30, 0),
                    IsActive = true,
                    CreatedAt = now
                }
            );
		}
	}

}
