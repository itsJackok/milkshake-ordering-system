using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using System;
using System.Threading.Tasks;

namespace MilkshakeAPI.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IEmailService _emailService;

        public PaymentsController(IUnitOfWork unitOfWork, IEmailService emailService)
        {
            _unitOfWork = unitOfWork;
            _emailService = emailService;
        }

        [HttpPost]
        public async Task<IActionResult> ProcessPayment([FromBody] InitializePaymentRequest request)
        {
            // 1. Validate order
            var order = await _unitOfWork.Orders.GetByIdAsync(request.OrderId);
            if (order == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Order not found"
                });
            }

            // (Optional) sanity check amount vs order total here

            var transactionId = $"MOCK-{order.Id}-{DateTime.UtcNow.Ticks}";

            var payment = new Payment
            {
                OrderId = order.Id,
                Amount = request.Amount,
                PaymentMethod = request.PaymentMethod,
                PaymentGateway = "PaymentGateway",
                TransactionId = transactionId,
                Status = "Completed",
                PaidAt = DateTime.UtcNow,
                PaymentGatewayResponse = "Payment processed successfully",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _unitOfWork.Payments.AddAsync(payment);

            // 3. Update order payment fields
            order.PaymentStatus = "Paid";
            order.PaymentTransactionId = transactionId;
            order.PaymentMethod = request.PaymentMethod;
            order.OrderStatus = "Confirmed";
            order.UpdatedAt = DateTime.UtcNow;

            await _unitOfWork.Orders.UpdateAsync(order);

            // 4. Save everything
            await _unitOfWork.SaveChangesAsync();

            // 5. Send payment receipt e-mail (uses your existing EmailService)
            await _emailService.SendPaymentReceiptEmailAsync(order.Id);

            return Ok(new
            {
                success = true,
                message = "Payment processed successfully.",
                transactionId
            });
        }
    }
}
