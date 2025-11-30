using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{

	public class User
	{
		public int Id { get; set; }
		public string FullName { get; set; } = string.Empty;
		public string Email { get; set; } = string.Empty;
		public string? MobileNumber { get; set; }
		public string PasswordHash { get; set; } = string.Empty;
		public string Role { get; set; } = "Patron";
		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? LastLoginAt { get; set; }
		public bool IsActive { get; set; } = true;

		public int TotalCompletedOrders { get; set; } = 0;
		public int TotalDrinksPurchased { get; set; } = 0;
		public int CurrentDiscountTier { get; set; } = 0;

		public ICollection<Order> Orders { get; set; } = new List<Order>();
		public ICollection<AuditLog> AuditLogs { get; set; } = new List<AuditLog>();
	}

}
