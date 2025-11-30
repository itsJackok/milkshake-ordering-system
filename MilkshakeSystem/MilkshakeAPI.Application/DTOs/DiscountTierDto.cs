using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class DiscountTierDto
	{
		public int Id { get; set; }
		public int TierLevel { get; set; }
		public string TierName { get; set; } = string.Empty;
		public int MinimumOrders { get; set; }
		public int MinimumDrinksPerOrder { get; set; }
		public decimal DiscountPercentage { get; set; }
		public decimal MaxDiscountAmount { get; set; }
		public string? Description { get; set; }
		public bool IsActive { get; set; }
	}

	public class CustomerDiscountInfo
	{
		public int CurrentTier { get; set; }
		public string CurrentTierName { get; set; } = string.Empty;
		public int TotalOrders { get; set; }
		public int TotalDrinks { get; set; }
		public decimal CurrentDiscountPercentage { get; set; }
		public decimal MaxDiscountAmount { get; set; }
		public DiscountTierDto? NextTier { get; set; }
		public int OrdersUntilNextTier { get; set; }
		public int DrinksUntilNextTier { get; set; }
	}

	public class CalculateDiscountRequest
	{
		public int UserId { get; set; }
		public decimal OrderSubtotal { get; set; }
		public int NumberOfDrinks { get; set; }
	}

	public class CalculateDiscountResponse
	{
		public int TierApplied { get; set; }
		public string TierName { get; set; } = string.Empty;
		public decimal DiscountPercentage { get; set; }
		public decimal CalculatedDiscount { get; set; }
		public decimal ActualDiscount { get; set; }
		public bool MaxCapApplied { get; set; }
	}
}
