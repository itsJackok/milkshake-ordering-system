using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Domain.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class OrdersController : ControllerBase
	{
		private readonly IOrderService _orderService;
		private readonly IEmailService _emailService;

		public OrdersController(IOrderService orderService, IEmailService emailService)
		{
			_orderService = orderService;
			_emailService = emailService;
		}

		
		[HttpPost]
		public async Task<ActionResult<ApiResponse<OrderResponse>>> CreateOrder([FromBody] CreateOrderRequest request)
		{
			var result = await _orderService.CreateOrderAsync(request);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			if (result.Data != null)
			{
				await _emailService.SendOrderConfirmationEmailAsync(result.Data.Id);
			}

			return Ok(result);
		}

	
		[HttpGet("{id}")]
		public async Task<ActionResult<ApiResponse<OrderResponse>>> GetOrder(int id)
		{
			var result = await _orderService.GetOrderByIdAsync(id);

			if (!result.Success)
			{
				return NotFound(result);
			}

			return Ok(result);
		}

		
		[HttpGet("user/{userId}")]
		public async Task<ActionResult<ApiResponse<List<OrderResponse>>>> GetUserOrders(int userId)
		{
			var result = await _orderService.GetUserOrdersAsync(userId);
			return Ok(result);
		}

		
		[HttpGet]
		public async Task<ActionResult<ApiResponse<List<OrderResponse>>>> GetAllOrders()
		{
			var result = await _orderService.GetAllOrdersAsync();
			return Ok(result);
		}

		
		[HttpPatch("{id}/status")]
		public async Task<ActionResult<ApiResponse>> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusRequest request)
		{
			var result = await _orderService.UpdateOrderStatusAsync(id, request);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}

		
		[HttpGet("dashboard/stats")]
		public async Task<ActionResult<DashboardStats>> GetDashboardStats()
		{
			var stats = await _orderService.GetDashboardStatsAsync();
			return Ok(stats);
		}

		
		[HttpGet("dashboard/top-sellers")]
		public async Task<ActionResult<List<TopSellerDto>>> GetTopSellers([FromQuery] int count = 5)
		{
			var topSellers = await _orderService.GetTopSellersAsync(count);
			return Ok(topSellers);
		}

		
		[HttpGet("dashboard/activity")]
		public async Task<ActionResult<List<ActivityDto>>> GetRecentActivity([FromQuery] int count = 5)
		{
			var activity = await _orderService.GetRecentActivityAsync(count);
			return Ok(activity);
		}
	}
}