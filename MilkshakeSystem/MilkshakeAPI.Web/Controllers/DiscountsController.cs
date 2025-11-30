using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class DiscountsController : ControllerBase
	{
		private readonly IDiscountService _discountService;

		public DiscountsController(IDiscountService discountService)
		{
			_discountService = discountService;
		}

	
		[HttpGet("tiers")]
		public async Task<ActionResult<List<DiscountTierDto>>> GetDiscountTiers()
		{
			var tiers = await _discountService.GetAllDiscountTiersAsync();
			return Ok(tiers);
		}

		
		[HttpGet("my-info/{userId}")]
		public async Task<ActionResult<CustomerDiscountInfo>> GetCustomerDiscountInfo(int userId)
		{
			var info = await _discountService.GetCustomerDiscountInfoAsync(userId);
			return Ok(info);
		}

	
		[HttpPost("calculate")]
		public async Task<ActionResult<CalculateDiscountResponse>> CalculateDiscount([FromBody] CalculateDiscountRequest request)
		{
			var result = await _discountService.CalculateDiscountAsync(request);
			return Ok(result);
		}

		
		[HttpPut("tiers/{id}")]
		public async Task<ActionResult<ApiResponse>> UpdateDiscountTier(int id, [FromBody] DiscountTierDto dto, [FromQuery] int updatedBy)
		{
			var result = await _discountService.UpdateDiscountTierAsync(id, dto, updatedBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}
	}
}