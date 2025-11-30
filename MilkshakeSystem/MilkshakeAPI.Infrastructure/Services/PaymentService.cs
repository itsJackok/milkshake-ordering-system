using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Infrastructure.Services
{
	public class PaymentService : IPaymentService
	{
		private readonly IUnitOfWork _unitOfWork;

		public PaymentService(IUnitOfWork unitOfWork)
		{
			_unitOfWork = unitOfWork;
		}

		public async Task<string> InitializePaymentAsync(int orderId, decimal amount)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(orderId);
			if (order == null)
			{
				throw new Exception("Order not found");
			}

			// Create payment record
			var payment = new Payment
			{
				OrderId = orderId,
				Amount = amount,
				PaymentMethod = "Card",
				PaymentGateway = "PayFast", // or Stripe
				Status = "Pending",
				CreatedAt = DateTime.UtcNow
			};

			await _unitOfWork.Payments.AddAsync(payment);
			await _unitOfWork.SaveChangesAsync();

			// Generate transaction ID
			var transactionId = $"TXN-{orderId}-{DateTime.Now.Ticks}";
			payment.TransactionId = transactionId;

			await _unitOfWork.Payments.UpdateAsync(payment);
			await _unitOfWork.SaveChangesAsync();

			// In production, integrate with actual payment gateway:
			// - PayFast (South African)
			// - Stripe (International)
			// - PayStack (African)

			// For now, return a mock payment URL
			// In production, this would be: var paymentUrl = await _payFastClient.InitializePayment(...)

			return $"https://payment-gateway.com/pay?tx={transactionId}&amount={amount}";
		}

		public async Task<bool> VerifyPaymentAsync(string transactionId)
		{
			var payments = await _unitOfWork.Payments.FindAsync(p => p.TransactionId == transactionId);
			var payment = payments.FirstOrDefault();

			if (payment == null) return false;

			// In production, verify with payment gateway:
			// var isValid = await _payFastClient.VerifyPayment(transactionId);

			// For development, assume payment is successful
			return payment.Status == "Completed";
		}

		public async Task ProcessPaymentCallbackAsync(string gatewayResponse)
		{
			// Parse gateway response (format depends on payment gateway)
			// For PayFast, you'd parse their POST data
			// For Stripe, you'd parse their webhook payload

			// Example structure (adjust based on your gateway):
			// var data = JsonSerializer.Deserialize<PaymentCallback>(gatewayResponse);

			// For now, mock implementation:
			// Assume gatewayResponse contains: "transactionId|status|message"
			var parts = gatewayResponse.Split('|');
			if (parts.Length < 2) return;

			var transactionId = parts[0];
			var status = parts[1];

			var payments = await _unitOfWork.Payments.FindAsync(p => p.TransactionId == transactionId);
			var payment = payments.FirstOrDefault();

			if (payment == null) return;

			payment.Status = status; // "Completed", "Failed", etc.
			payment.PaymentGatewayResponse = gatewayResponse;
			payment.UpdatedAt = DateTime.UtcNow;

			if (status == "Completed")
			{
				payment.PaidAt = DateTime.UtcNow;

				// Update order
				var order = await _unitOfWork.Orders.GetByIdAsync(payment.OrderId);
				if (order != null)
				{
					order.PaymentStatus = "Paid";
					order.PaymentTransactionId = transactionId;
					order.UpdatedAt = DateTime.UtcNow;
					await _unitOfWork.Orders.UpdateAsync(order);
				}
			}
			else
			{
				payment.FailureReason = parts.Length > 2 ? parts[2] : "Payment failed";
			}

			await _unitOfWork.Payments.UpdateAsync(payment);
			await _unitOfWork.SaveChangesAsync();
		}
	}

	// Payment gateway integration examples:

	// For PayFast (South African):
	/*
    public class PayFastConfig
    {
        public string MerchantId { get; set; }
        public string MerchantKey { get; set; }
        public string PassPhrase { get; set; }
        public string ProcessUrl { get; set; } = "https://www.payfast.co.za/eng/process";
    }
    
    private string GeneratePayFastUrl(Order order, PayFastConfig config)
    {
        var data = new Dictionary<string, string>
        {
            { "merchant_id", config.MerchantId },
            { "merchant_key", config.MerchantKey },
            { "return_url", "https://yoursite.com/payment/success" },
            { "cancel_url", "https://yoursite.com/payment/cancel" },
            { "notify_url", "https://yoursite.com/api/payments/callback" },
            { "amount", order.TotalCost.ToString("F2") },
            { "item_name", $"Order #{order.Id}" },
            { "item_description", $"{order.OrderItems.Count} milkshakes" }
        };
        
        // Generate signature
        var signature = GeneratePayFastSignature(data, config.PassPhrase);
        data.Add("signature", signature);
        
        // Build URL
        var queryString = string.Join("&", data.Select(kvp => $"{kvp.Key}={Uri.EscapeDataString(kvp.Value)}"));
        return $"{config.ProcessUrl}?{queryString}";
    }
    */

	// For Stripe (International):
	/*
    using Stripe;
    using Stripe.Checkout;
    
    private async Task<string> CreateStripeCheckoutSession(Order order)
    {
        var options = new SessionCreateOptions
        {
            PaymentMethodTypes = new List<string> { "card" },
            LineItems = new List<SessionLineItemOptions>
            {
                new SessionLineItemOptions
                {
                    PriceData = new SessionLineItemPriceDataOptions
                    {
                        UnitAmount = (long)(order.TotalCost * 100), // Amount in cents
                        Currency = "zar",
                        ProductData = new SessionLineItemPriceDataProductDataOptions
                        {
                            Name = $"Milkshake Order #{order.Id}",
                            Description = $"{order.OrderItems.Count} delicious milkshakes"
                        }
                    },
                    Quantity = 1
                }
            },
            Mode = "payment",
            SuccessUrl = "https://yoursite.com/payment/success?session_id={CHECKOUT_SESSION_ID}",
            CancelUrl = "https://yoursite.com/payment/cancel"
        };
        
        var service = new SessionService();
        Session session = await service.CreateAsync(options);
        
        return session.Url;
    }
    */
}
