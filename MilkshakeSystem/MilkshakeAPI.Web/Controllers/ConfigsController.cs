using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class ConfigsController : ControllerBase
	{
		private readonly IConfigurationService _configurationService;

		public ConfigsController(IConfigurationService configurationService)
		{
			_configurationService = configurationService;
		}

		
		[HttpGet]
		public async Task<ActionResult<List<ConfigurationDto>>> GetAllConfigurations()
		{
			var configurations = await _configurationService.GetAllConfigurationsAsync();
			return Ok(configurations);
		}

		
		[HttpGet("{key}")]
		public async Task<ActionResult<ConfigurationDto>> GetConfiguration(string key   
			)
		{
			var configuration = await _configurationService.GetConfigurationByKeyAsync(key);

			if (configuration == null)
			{
				return NotFound(new { message = "Configuration not found" });
			}

			return Ok(configuration);
		}

		
		[HttpPut("{key}")]
		public async Task<ActionResult<ApiResponse>> UpdateConfiguration(string key, [FromBody] UpdateConfigurationRequest request, [FromQuery] int updatedBy)
		{
			var result = await _configurationService.UpdateConfigurationAsync(key, request, updatedBy);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}
	}
}