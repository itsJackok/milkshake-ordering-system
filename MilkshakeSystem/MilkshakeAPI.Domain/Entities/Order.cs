using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{

	public class Order
	{
		public int Id { get; set; }
		public int UserId { get; set; }
		public User? User { get; set; }
		public int RestaurantId { get; set; }
		public Restaurant? Restaurant { get; set; }

		public DateTime OrderDate { get; set; } = DateTime.UtcNow;
		public DateTime PickupTime { get; set; }

		public decimal Subtotal { get; set; }
		public decimal VAT { get; set; }
		public decimal DiscountAmount { get; set; } = 0;
		public int DiscountTierApplied { get; set; } = 0;
		public decimal TotalCost { get; set; }

		public string PaymentStatus { get; set; } = "Pending";
		public string? PaymentTransactionId { get; set; }
		public string? PaymentMethod { get; set; }

		public string OrderStatus { get; set; } = "Pending";
		public DateTime? CompletedAt { get; set; }
		public DateTime? CancelledAt { get; set; }
		public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

		public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
		public Payment? Payment { get; set; }
		public ICollection<EmailLog> EmailLogs { get; set; } = new List<EmailLog>();
	}

}
