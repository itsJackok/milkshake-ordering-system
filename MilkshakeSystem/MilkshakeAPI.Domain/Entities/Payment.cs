using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
	public class Payment
	{
		public int Id { get; set; }
		public int OrderId { get; set; }
		public Order? Order { get; set; }

		public decimal Amount { get; set; }
		public string PaymentMethod { get; set; } = string.Empty;
		public string? PaymentGateway { get; set; }
		public string? TransactionId { get; set; }
		public string? PaymentGatewayReference { get; set; }
		public string Status { get; set; } = "Pending";
		public DateTime? PaidAt { get; set; }
		public string? PaymentGatewayResponse { get; set; }
		public string? FailureReason { get; set; }

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
	}

}
