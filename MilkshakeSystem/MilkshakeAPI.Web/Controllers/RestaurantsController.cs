using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class RestaurantsController : ControllerBase
	{
		private readonly IRestaurantService _restaurantService;

		public RestaurantsController(IRestaurantService restaurantService)
		{
			_restaurantService = restaurantService;
		}

		[HttpGet]
		public async Task<ActionResult<List<RestaurantDto>>> GetAllRestaurants()
		{
			var restaurants = await _restaurantService.GetAllRestaurantsAsync();
			return Ok(restaurants);
		}

		[HttpGet("{id}")]
		public async Task<ActionResult<RestaurantDto>> GetRestaurant(int id)
		{
			var restaurant = await _restaurantService.GetRestaurantByIdAsync(id);

			if (restaurant == null)
			{
				return NotFound(new { message = "Restaurant not found" });
			}

			return Ok(restaurant);
		}

		[HttpGet("{id}/available-times")]
		public async Task<ActionResult<List<AvailableTimeSlot>>> GetAvailableTimeSlots(int id, [FromQuery] DateTime date)
		{
			var slots = await _restaurantService.GetAvailableTimeSlotsAsync(id, date);
			return Ok(slots);
		}

	
		[HttpPost]
		public async Task<ActionResult<ApiResponse<RestaurantDto>>> CreateRestaurant([FromBody] CreateRestaurantRequest request, [FromQuery] int createdBy)
		{
			var result = await _restaurantService.CreateRestaurantAsync(request, createdBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}

	
		[HttpPut("{id}")]
		public async Task<ActionResult<ApiResponse<RestaurantDto>>> UpdateRestaurant(int id, [FromBody] CreateRestaurantRequest request, [FromQuery] int updatedBy)
		{
			var result = await _restaurantService.UpdateRestaurantAsync(id, request, updatedBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}
	}
}