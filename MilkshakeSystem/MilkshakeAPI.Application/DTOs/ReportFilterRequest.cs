using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class ReportFilterRequest
	{
		public DateTime? StartDate { get; set; }
		public DateTime? EndDate { get; set; }
		public string? PaymentStatus { get; set; }
		public string? OrderStatus { get; set; }
		public int? RestaurantId { get; set; }
		public int PageNumber { get; set; } = 1;
		public int PageSize { get; set; } = 10;
	}

	public class OrderReportDto
	{
		public int Id { get; set; }
		public DateTime OrderDate { get; set; }
		public string Time { get; set; } = string.Empty;
		public string CustomerName { get; set; } = string.Empty;
		public string RestaurantName { get; set; } = string.Empty;
		public int NumberOfDrinks { get; set; }
		public decimal TotalCost { get; set; }
		public string PaymentStatus { get; set; } = string.Empty;
		public string OrderStatus { get; set; } = string.Empty;
	}

	public class PagedResult<T>
	{
		public List<T> Data { get; set; } = new();
		public int TotalRecords { get; set; }
		public int PageNumber { get; set; }
		public int PageSize { get; set; }
		public int TotalPages { get; set; }
	}

	public class TrendDataDto
	{
		public string Label { get; set; } = string.Empty;
		public int OrderCount { get; set; }
		public decimal Revenue { get; set; }
	}

	public class AuditLogDto
	{
		public int Id { get; set; }
		public string UserName { get; set; } = string.Empty;
		public string EntityType { get; set; } = string.Empty;
		public int EntityId { get; set; }
		public string Action { get; set; } = string.Empty;
		public string? FieldChanged { get; set; }
		public string? OldValue { get; set; }
		public string? NewValue { get; set; }
		public DateTime Timestamp { get; set; }
	}

}
