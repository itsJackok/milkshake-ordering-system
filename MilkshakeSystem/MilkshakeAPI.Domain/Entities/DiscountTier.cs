using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
	public class DiscountTier
	{
		public int Id { get; set; }
		public int TierLevel { get; set; } // 1, 2, 3
		public string TierName { get; set; } = string.Empty;
		public int MinimumOrders { get; set; }
		public int MinimumDrinksPerOrder { get; set; }
		public decimal DiscountPercentage { get; set; }
		public decimal MaxDiscountAmount { get; set; }
		public bool IsActive { get; set; } = true;
		public string? Description { get; set; }

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? LastUpdated { get; set; }
		public int? LastUpdatedBy { get; set; }
	}

}
