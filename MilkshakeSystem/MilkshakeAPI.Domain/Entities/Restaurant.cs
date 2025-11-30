using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
		public class Restaurant
	{
		public int Id { get; set; }
		public string Name { get; set; } = string.Empty;
		public string Address { get; set; } = string.Empty;
		public string? PhoneNumber { get; set; }
		public TimeSpan OpeningTime { get; set; } = new TimeSpan(8, 0, 0);
		public TimeSpan ClosingTime { get; set; } = new TimeSpan(20, 0, 0);
		public bool IsActive { get; set; } = true;

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? LastUpdated { get; set; }
		public int? LastUpdatedBy { get; set; }

		public ICollection<Order> Orders { get; set; } = new List<Order>();
	}

}
