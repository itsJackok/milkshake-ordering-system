using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Infrastructure.Services
{
	public class EmailService : IEmailService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly string _smtpHost;
		private readonly int _smtpPort;
		private readonly string _fromEmail;
		private readonly string _fromName;
		private readonly string? _smtpUsername;
		private readonly string? _smtpPassword;

		public EmailService(IUnitOfWork unitOfWork)
		{
			_unitOfWork = unitOfWork;

			// These would typically come from configuration
			// For now, using defaults (you'll configure these in appsettings.json)
			_smtpHost = "smtp.gmail.com"; // Or your SMTP server
			_smtpPort = 587;
			_fromEmail = "noreply@milkyshaky.com";
			_fromName = "Milky Shaky Drinks";
			_smtpUsername = null; // Set from config
			_smtpPassword = null; // Set from config
		}

		public async Task SendOrderConfirmationEmailAsync(int orderId)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(orderId);
			if (order == null) return;

			var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);
			if (user == null) return;

			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(order.RestaurantId);
			var orderItems = await _unitOfWork.OrderItems.FindAsync(oi => oi.OrderId == orderId);

			var subject = $"Order Confirmation #{order.Id} - Milky Shaky Drinks";
			var body = GenerateOrderConfirmationHtml(order, user, restaurant, orderItems.ToList());

			await SendEmailAsync(user.Email, subject, body, orderId, "OrderConfirmation");
		}

		public async Task SendPaymentReceiptEmailAsync(int orderId)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(orderId);
			if (order == null) return;

			var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);
			if (user == null) return;

			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(order.RestaurantId);
			var orderItems = await _unitOfWork.OrderItems.FindAsync(oi => oi.OrderId == orderId);

			var subject = $"Payment Receipt #{order.Id} - Milky Shaky Drinks";
			var body = GeneratePaymentReceiptHtml(order, user, restaurant, orderItems.ToList());

			await SendEmailAsync(user.Email, subject, body, orderId, "PaymentReceipt");
		}

		private async Task SendEmailAsync(string toEmail, string subject, string body, int? orderId, string emailType)
		{
			var emailLog = new EmailLog
			{
				ToEmail = toEmail,
				Subject = subject,
				Body = body,
				OrderId = orderId,
				EmailType = emailType,
				Status = "Pending",
				CreatedAt = DateTime.UtcNow
			};

			try
			{
				// For development, just log the email (don't actually send)
				// In production, uncomment the SMTP code below

				/*
                using var client = new SmtpClient(_smtpHost, _smtpPort);
                client.EnableSsl = true;
                
                if (!string.IsNullOrEmpty(_smtpUsername))
                {
                    client.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                }

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(_fromEmail, _fromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };
                mailMessage.To.Add(toEmail);

                await client.SendMailAsync(mailMessage);
                */

				emailLog.Status = "Sent";
				emailLog.SentAt = DateTime.UtcNow;
			}
			catch (Exception ex)
			{
				emailLog.Status = "Failed";
				emailLog.ErrorMessage = ex.Message;
				emailLog.RetryCount++;
			}

			await _unitOfWork.EmailLogs.AddAsync(emailLog);
			await _unitOfWork.SaveChangesAsync();
		}

		private string GenerateOrderConfirmationHtml(Order order, User user, Restaurant? restaurant, List<OrderItem> items)
		{
			return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #0066FF; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background: #f9f9f9; }}
        .order-details {{ background: white; padding: 15px; margin: 15px 0; border-radius: 5px; }}
        .item {{ border-bottom: 1px solid #eee; padding: 10px 0; }}
        .total {{ font-size: 18px; font-weight: bold; margin-top: 15px; }}
        .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Order Confirmation</h1>
            <p>Thank you for your order, {user.FullName}!</p>
        </div>
        <div class='content'>
            <div class='order-details'>
                <h2>Order #{order.Id}</h2>
                <p><strong>Order Date:</strong> {order.OrderDate:dd/MM/yyyy HH:mm}</p>
                <p><strong>Pickup Time:</strong> {order.PickupTime:dd/MM/yyyy HH:mm}</p>
                <p><strong>Restaurant:</strong> {restaurant?.Name ?? ""}</p>
                <p><strong>Address:</strong> {restaurant?.Address ?? ""}</p>
                
                <h3>Your Drinks:</h3>
                {string.Join("", items.Select((item, index) => $@"
                <div class='item'>
                    <strong>Drink {index + 1}</strong><br/>
                    Flavour: {item.Flavour?.Name ?? ""} (R{item.FlavourPrice:F2})<br/>
                    Topping: {item.Topping?.Name ?? ""} (R{item.ToppingPrice:F2})<br/>
                    Consistency: {item.Consistency?.Name ?? ""} (R{item.ConsistencyPrice:F2})<br/>
                    <strong>Subtotal: R{item.ItemTotal:F2}</strong>
                </div>
                "))}
                
                <div class='total'>
                    <p>Subtotal: R{order.Subtotal:F2}</p>
                    <p>VAT (15%): R{order.VAT:F2}</p>
                    {(order.DiscountAmount > 0 ? $"<p>Discount: -R{order.DiscountAmount:F2}</p>" : "")}
                    <p>Total: R{order.TotalCost:F2}</p>
                    <p>Payment Status: {order.PaymentStatus}</p>
                </div>
            </div>
            
            <p>We'll have your delicious milkshakes ready for pickup!</p>
            <p>Please arrive at the restaurant around your selected pickup time.</p>
        </div>
        <div class='footer'>
            <p>Milky Shaky Drinks © 2025</p>
            <p>For questions, contact us at support@milkyshaky.com</p>
        </div>
    </div>
</body>
</html>";
		}

		private string GeneratePaymentReceiptHtml(Order order, User user, Restaurant? restaurant, List<OrderItem> items)
		{
			return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #4CAF50; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background: #f9f9f9; }}
        .receipt {{ background: white; padding: 15px; margin: 15px 0; border-radius: 5px; }}
        .item {{ border-bottom: 1px solid #eee; padding: 10px 0; }}
        .total {{ font-size: 18px; font-weight: bold; margin-top: 15px; color: #4CAF50; }}
        .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Payment Receipt</h1>
            <p>Payment Successful!</p>
        </div>
        <div class='content'>
            <div class='receipt'>
                <h2>Receipt for Order #{order.Id}</h2>
                <p><strong>Customer:</strong> {user.FullName}</p>
                <p><strong>Email:</strong> {user.Email}</p>
                <p><strong>Order Date:</strong> {order.OrderDate:dd/MM/yyyy HH:mm}</p>
                <p><strong>Payment Method:</strong> {order.PaymentMethod ?? "Card"}</p>
                <p><strong>Transaction ID:</strong> {order.PaymentTransactionId ?? "N/A"}</p>
                
                <h3>Order Summary:</h3>
                {string.Join("", items.Select((item, index) => $@"
                <div class='item'>
                    <strong>Drink {index + 1}</strong> - R{item.ItemTotal:F2}
                </div>
                "))}
                
                <div class='total'>
                    <p>Subtotal: R{order.Subtotal:F2}</p>
                    <p>VAT (15%): R{order.VAT:F2}</p>
                    {(order.DiscountAmount > 0 ? $"<p>Discount: -R{order.DiscountAmount:F2}</p>" : "")}
                    <p>TOTAL PAID: R{order.TotalCost:F2}</p>
                </div>
                
                <p><strong>Pickup Location:</strong></p>
                <p>{restaurant?.Name ?? ""}</p>
                <p>{restaurant?.Address ?? ""}</p>
                <p><strong>Pickup Time:</strong> {order.PickupTime:dd/MM/yyyy HH:mm}</p>
            </div>
            
            <p>Thank you for your payment! Your order is being prepared.</p>
            <p>Please present this receipt when collecting your order.</p>
        </div>
        <div class='footer'>
            <p>Milky Shaky Drinks © 2025</p>
            <p>Questions? Email us at support@milkyshaky.com</p>
        </div>
    </div>
</body>
</html>";
		}
	}
}
