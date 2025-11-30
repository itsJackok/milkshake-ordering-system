using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class AuthController : ControllerBase
	{
		private readonly IAuthService _authService;

		public AuthController(IAuthService authService)
		{
			_authService = authService;
		}

		
		[HttpPost("register")]
		public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
		{
			var result = await _authService.RegisterAsync(request);

			if (!result.Success)
			{
				return BadRequest(result);
			}

			return Ok(result);
		}

		[HttpPost("login")]
		public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
		{
			var result = await _authService.LoginAsync(request);

			if (!result.Success)
			{
				return Unauthorized(result);
			}

			return Ok(result);
		}

		
		[HttpGet("check-email/{email}")]
		public async Task<ActionResult<bool>> CheckEmail(string email)
		{
			var exists = await _authService.EmailExistsAsync(email);
			return Ok(new { exists });
		}
	}
}