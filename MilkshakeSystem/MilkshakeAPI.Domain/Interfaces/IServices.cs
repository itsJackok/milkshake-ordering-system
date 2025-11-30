using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Interfaces
{
	public interface IEmailService
	{
		Task SendOrderConfirmationEmailAsync(int orderId);
		Task SendPaymentReceiptEmailAsync(int orderId);
	}

	public interface IPaymentService
	{
		Task<string> InitializePaymentAsync(int orderId, decimal amount);
		Task<bool> VerifyPaymentAsync(string transactionId);
		Task ProcessPaymentCallbackAsync(string gatewayResponse);
	}

	public interface IAuditService
	{
		Task LogChangeAsync(int userId, string entityType, int entityId, string action,
			string? fieldChanged = null, string? oldValue = null, string? newValue = null);
	}

}
