using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class DashboardStats
	{
		public int TodayOrders { get; set; }
		public int TodayOrdersChange { get; set; }
		public decimal TodayRevenue { get; set; }
		public decimal TodayRevenueChange { get; set; }
		public string PopularFlavour { get; set; } = string.Empty;
		public int PopularFlavourCount { get; set; }
		public int PendingOrders { get; set; }
	}

	public class TopSellerDto
	{
		public string Name { get; set; } = string.Empty;
		public int OrderCount { get; set; }
		public decimal Percentage { get; set; }
	}

	public class ActivityDto
	{
		public string Type { get; set; } = string.Empty;
		public string Title { get; set; } = string.Empty;
		public string Subtitle { get; set; } = string.Empty;
		public DateTime Timestamp { get; set; }
		public string Icon { get; set; } = string.Empty;
		public string Color { get; set; } = string.Empty;
	}

}
