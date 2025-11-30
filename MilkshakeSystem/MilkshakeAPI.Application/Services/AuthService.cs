using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using MilkshakeAPI.Application.DTOs;
using BCrypt.Net;

namespace MilkshakeAPI.Application.Services
{
    public class AuthService : IAuthService
	{
		private readonly IUnitOfWork _unitOfWork;

		public AuthService(IUnitOfWork unitOfWork)
		{
			_unitOfWork = unitOfWork;
		}

		public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
		{
			// Check if email already exists
			var existingUser = await _unitOfWork.Users.FindAsync(u => u.Email == request.Email);
			if (existingUser.Any())
			{
				return new AuthResponse
				{
					Success = false,
					Message = "Email already exists"
				};
			}

			// Hash password
			var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

			// Create user
			var user = new User
			{
				FullName = request.FullName,
				Email = request.Email,
				MobileNumber = request.MobileNumber,
				PasswordHash = passwordHash,
				Role = request.Role,
				CreatedAt = DateTime.UtcNow,
				IsActive = true
			};

			await _unitOfWork.Users.AddAsync(user);
			await _unitOfWork.SaveChangesAsync();

			return new AuthResponse
			{
				Success = true,
				Message = "Registration successful",
				UserId = user.Id,
				FullName = user.FullName,
				Email = user.Email,
				Role = user.Role,
				CurrentDiscountTier = 0,
				DiscountTierName = "None"
			};
		}

		public async Task<AuthResponse> LoginAsync(LoginRequest request)
		{
			// Find user by email
			var users = await _unitOfWork.Users.FindAsync(u => u.Email == request.Email && u.IsActive);
			var user = users.FirstOrDefault();

			if (user == null)
			{
				return new AuthResponse
				{
					Success = false,
					Message = "Invalid email or password"
				};
			}

			// Verify password
			if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
			{
				return new AuthResponse
				{
					Success = false,
					Message = "Invalid email or password"
				};
			}

			// Update last login
			user.LastLoginAt = DateTime.UtcNow;
			await _unitOfWork.Users.UpdateAsync(user);
			await _unitOfWork.SaveChangesAsync();

			// Get discount tier name
			string tierName = "None";
			if (user.CurrentDiscountTier > 0)
			{
				var tiers = await _unitOfWork.DiscountTiers.FindAsync(
					t => t.TierLevel == user.CurrentDiscountTier && t.IsActive);
				var tier = tiers.FirstOrDefault();
				if (tier != null)
				{
					tierName = tier.TierName;
				}
			}

			return new AuthResponse
			{
				Success = true,
				Message = "Login successful",
				UserId = user.Id,
				FullName = user.FullName,
				Email = user.Email,
				Role = user.Role,
				CurrentDiscountTier = user.CurrentDiscountTier,
				DiscountTierName = tierName
			};
		}

		public async Task<bool> EmailExistsAsync(string email)
		{
			var users = await _unitOfWork.Users.FindAsync(u => u.Email == email);
			return users.Any();
		}
	}
}
