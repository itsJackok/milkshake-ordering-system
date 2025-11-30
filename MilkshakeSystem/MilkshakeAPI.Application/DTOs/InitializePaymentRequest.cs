using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{

	public class InitializePaymentRequest
	{
        public int OrderId { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = "Card";
        public string CardLastFour { get; set; } = string.Empty;
        public string CardHolder { get; set; } = string.Empty;
    }

	public class InitializePaymentResponse
	{
		public bool Success { get; set; }
		public string Message { get; set; } = string.Empty;
		public string? PaymentUrl { get; set; }
		public string? TransactionId { get; set; }
	}

	public class PaymentCallbackRequest
	{
		public string TransactionId { get; set; } = string.Empty;
		public string Status { get; set; } = string.Empty;
		public string? GatewayResponse { get; set; }
	}

	public class PaymentStatusResponse
	{
		public int OrderId { get; set; }
		public string Status { get; set; } = string.Empty;
		public decimal Amount { get; set; }
		public DateTime? PaidAt { get; set; }
		public string? TransactionId { get; set; }
	}


}
