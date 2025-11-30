using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class CreateOrderRequest
	{
		public int UserId { get; set; }
		public int RestaurantId { get; set; }
		public DateTime PickupTime { get; set; }
		public List<OrderItemRequest> Items { get; set; } = new();
	}

	public class OrderItemRequest
	{
		public int FlavourId { get; set; }
		public int ToppingId { get; set; }
		public int ConsistencyId { get; set; }
	}

	public class OrderResponse
	{
		public int Id { get; set; }
		public DateTime OrderDate { get; set; }
		public DateTime PickupTime { get; set; }
		public string UserName { get; set; } = string.Empty;
		public string UserEmail { get; set; } = string.Empty;
		public string RestaurantName { get; set; } = string.Empty;
		public string RestaurantAddress { get; set; } = string.Empty;
		public decimal Subtotal { get; set; }
		public decimal VAT { get; set; }
		public decimal VATPercentage { get; set; }
		public decimal DiscountAmount { get; set; }
		public int DiscountTierApplied { get; set; }
		public string DiscountTierName { get; set; } = string.Empty;
		public decimal TotalCost { get; set; }
		public string PaymentStatus { get; set; } = string.Empty;
		public string OrderStatus { get; set; } = string.Empty;
		public int NumberOfDrinks { get; set; }
		public List<OrderItemResponse> Items { get; set; } = new();
	}

	public class OrderItemResponse
	{
		public int Id { get; set; }
		public string FlavourName { get; set; } = string.Empty;
		public string ToppingName { get; set; } = string.Empty;
		public string ConsistencyName { get; set; } = string.Empty;
		public decimal FlavourPrice { get; set; }
		public decimal ToppingPrice { get; set; }
		public decimal ConsistencyPrice { get; set; }
		public decimal ItemTotal { get; set; }
	}

	public class UpdateOrderStatusRequest
	{
		public string OrderStatus { get; set; } = string.Empty;
		public string? PaymentStatus { get; set; }
	}
}
