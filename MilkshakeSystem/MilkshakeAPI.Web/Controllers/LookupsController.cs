using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class LookupsController : ControllerBase
	{
		private readonly ILookupService _lookupService;

		public LookupsController(ILookupService lookupService)
		{
			_lookupService = lookupService;
		}

		[HttpGet("flavours")]
		public async Task<ActionResult<List<LookupDto>>> GetFlavours()
		{
			var flavours = await _lookupService.GetFlavoursAsync();
			return Ok(flavours);
		}

	
		[HttpGet("toppings")]
		public async Task<ActionResult<List<LookupDto>>> GetToppings()
		{
			var toppings = await _lookupService.GetToppingsAsync();
			return Ok(toppings);
		}


		[HttpGet("consistencies")]
		public async Task<ActionResult<List<LookupDto>>> GetConsistencies()
		{
			var consistencies = await _lookupService.GetConsistenciesAsync();
			return Ok(consistencies);
		}

		
		[HttpGet]
		public async Task<ActionResult<List<LookupDto>>> GetAllLookups()
		{
			var lookups = await _lookupService.GetAllLookupsAsync();
			return Ok(lookups);
		}

	
		[HttpPost]
		public async Task<ActionResult<ApiResponse<LookupDto>>> CreateLookup([FromBody] CreateLookupRequest request, [FromQuery] int createdBy)
		{
			var result = await _lookupService.CreateLookupAsync(request, createdBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}

	
		[HttpPut("{id}")]
		public async Task<ActionResult<ApiResponse<LookupDto>>> UpdateLookup(int id, [FromBody] UpdateLookupRequest request, [FromQuery] int updatedBy)
		{
			var result = await _lookupService.UpdateLookupAsync(id, request, updatedBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}

		[HttpDelete("{id}")]
		public async Task<ActionResult<ApiResponse>> DeleteLookup(int id, [FromQuery] int deletedBy)
		{
			var result = await _lookupService.DeleteLookupAsync(id, deletedBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}
	}
}