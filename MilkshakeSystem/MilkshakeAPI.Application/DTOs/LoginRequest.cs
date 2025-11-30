using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class LoginRequest
	{
		public string Email { get; set; } = string.Empty;
		public string Password { get; set; } = string.Empty;
	}

	public class RegisterRequest
	{
		public string FullName { get; set; } = string.Empty;
		public string Email { get; set; } = string.Empty;
		public string MobileNumber { get; set; } = string.Empty;
		public string Password { get; set; } = string.Empty;
		public string Role { get; set; } = "Patron";
	}

	public class AuthResponse
	{
		public bool Success { get; set; }
		public string Message { get; set; } = string.Empty;
		public int UserId { get; set; }
		public string FullName { get; set; } = string.Empty;
		public string Email { get; set; } = string.Empty;
		public string Role { get; set; } = string.Empty;
		public int CurrentDiscountTier { get; set; }
		public string DiscountTierName { get; set; } = string.Empty;
	}

}
