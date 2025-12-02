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
            var order = await _unitOfWork.Orders.GetByIdAsync(request.OrderId);
            if (order == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Order not found"
                });
            }


            var transactionId = $"{order.Id}-{DateTime.UtcNow.Ticks}";

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

            order.PaymentStatus = "Paid";
            order.PaymentTransactionId = transactionId;
            order.PaymentMethod = request.PaymentMethod;
            order.OrderStatus = "Confirmed";
            order.UpdatedAt = DateTime.UtcNow;

            await _unitOfWork.Orders.UpdateAsync(order);

            await _unitOfWork.SaveChangesAsync();

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
