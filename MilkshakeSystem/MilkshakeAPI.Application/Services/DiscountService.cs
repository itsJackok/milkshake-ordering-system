using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;

namespace MilkshakeAPI.Application.Services
{
	public class DiscountService : IDiscountService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IAuditService _auditService;

		public DiscountService(IUnitOfWork unitOfWork, IAuditService auditService)
		{
			_unitOfWork = unitOfWork;
			_auditService = auditService;
		}

		public async Task<CalculateDiscountResponse> CalculateDiscountAsync(CalculateDiscountRequest request)
		{
			var user = await _unitOfWork.Users.GetByIdAsync(request.UserId);
			if (user == null)
			{
				return new CalculateDiscountResponse
				{
					TierApplied = 0,
					TierName = "None",
					DiscountPercentage = 0,
					CalculatedDiscount = 0,
					ActualDiscount = 0,
					MaxCapApplied = false
				};
			}

			var eligibleTiers = await _unitOfWork.DiscountTiers.FindAsync(
				t => t.IsActive &&
					 t.MinimumOrders <= user.TotalCompletedOrders &&
					 t.MinimumDrinksPerOrder <= request.NumberOfDrinks);

			var tier = eligibleTiers.OrderByDescending(t => t.TierLevel).FirstOrDefault();

			if (tier == null)
			{
				return new CalculateDiscountResponse
				{
					TierApplied = 0,
					TierName = "None",
					DiscountPercentage = 0,
					CalculatedDiscount = 0,
					ActualDiscount = 0,
					MaxCapApplied = false
				};
			}

			var calculatedDiscount = request.OrderSubtotal * (tier.DiscountPercentage / 100);
			var actualDiscount = Math.Min(calculatedDiscount, tier.MaxDiscountAmount);

			return new CalculateDiscountResponse
			{
				TierApplied = tier.TierLevel,
				TierName = tier.TierName,
				DiscountPercentage = tier.DiscountPercentage,
				CalculatedDiscount = calculatedDiscount,
				ActualDiscount = actualDiscount,
				MaxCapApplied = calculatedDiscount > tier.MaxDiscountAmount
			};
		}

		public async Task<CustomerDiscountInfo> GetCustomerDiscountInfoAsync(int userId)
		{
			var user = await _unitOfWork.Users.GetByIdAsync(userId);
			if (user == null)
			{
				throw new Exception("User not found");
			}

			var allTiers = (await _unitOfWork.DiscountTiers.FindAsync(t => t.IsActive))
				.OrderBy(t => t.TierLevel)
				.ToList();

			var currentTier = allTiers.FirstOrDefault(t => t.TierLevel == user.CurrentDiscountTier);
			var nextTier = allTiers.FirstOrDefault(t => t.TierLevel == user.CurrentDiscountTier + 1);

			int ordersUntilNext = 0;
			int drinksUntilNext = 0;

			if (nextTier != null)
			{
				ordersUntilNext = Math.Max(0, nextTier.MinimumOrders - user.TotalCompletedOrders);
				drinksUntilNext = Math.Max(0, nextTier.MinimumDrinksPerOrder);
			}

			return new CustomerDiscountInfo
			{
				CurrentTier = user.CurrentDiscountTier,
				CurrentTierName = currentTier?.TierName ?? "None",
				TotalOrders = user.TotalCompletedOrders,
				TotalDrinks = user.TotalDrinksPurchased,
				CurrentDiscountPercentage = currentTier?.DiscountPercentage ?? 0,
				MaxDiscountAmount = currentTier?.MaxDiscountAmount ?? 0,
				NextTier = nextTier != null ? new DiscountTierDto
				{
					Id = nextTier.Id,
					TierLevel = nextTier.TierLevel,
					TierName = nextTier.TierName,
					MinimumOrders = nextTier.MinimumOrders,
					MinimumDrinksPerOrder = nextTier.MinimumDrinksPerOrder,
					DiscountPercentage = nextTier.DiscountPercentage,
					MaxDiscountAmount = nextTier.MaxDiscountAmount,
					Description = nextTier.Description,
					IsActive = nextTier.IsActive
				} : null,
				OrdersUntilNextTier = ordersUntilNext,
				DrinksUntilNextTier = drinksUntilNext
			};
		}

		public async Task<List<DiscountTierDto>> GetAllDiscountTiersAsync()
		{
			var tiers = await _unitOfWork.DiscountTiers.GetAllAsync();

			return tiers.Select(t => new DiscountTierDto
			{
				Id = t.Id,
				TierLevel = t.TierLevel,
				TierName = t.TierName,
				MinimumOrders = t.MinimumOrders,
				MinimumDrinksPerOrder = t.MinimumDrinksPerOrder,
				DiscountPercentage = t.DiscountPercentage,
				MaxDiscountAmount = t.MaxDiscountAmount,
				Description = t.Description,
				IsActive = t.IsActive
			}).OrderBy(t => t.TierLevel).ToList();
		}

		public async Task<ApiResponse> UpdateDiscountTierAsync(int tierId, DiscountTierDto dto, int updatedBy)
		{
			var tier = await _unitOfWork.DiscountTiers.GetByIdAsync(tierId);
			if (tier == null)
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Discount tier not found"
				};
			}

			if (tier.MinimumOrders != dto.MinimumOrders)
			{
				await _auditService.LogChangeAsync(updatedBy, "DiscountTier", tierId, "Update",
					"MinimumOrders", tier.MinimumOrders.ToString(), dto.MinimumOrders.ToString());
			}

			if (tier.MinimumDrinksPerOrder != dto.MinimumDrinksPerOrder)
			{
				await _auditService.LogChangeAsync(updatedBy, "DiscountTier", tierId, "Update",
					"MinimumDrinksPerOrder", tier.MinimumDrinksPerOrder.ToString(), dto.MinimumDrinksPerOrder.ToString());
			}

			if (tier.DiscountPercentage != dto.DiscountPercentage)
			{
				await _auditService.LogChangeAsync(updatedBy, "DiscountTier", tierId, "Update",
					"DiscountPercentage", tier.DiscountPercentage.ToString(), dto.DiscountPercentage.ToString());
			}

			if (tier.MaxDiscountAmount != dto.MaxDiscountAmount)
			{
				await _auditService.LogChangeAsync(updatedBy, "DiscountTier", tierId, "Update",
					"MaxDiscountAmount", tier.MaxDiscountAmount.ToString(), dto.MaxDiscountAmount.ToString());
			}

			tier.MinimumOrders = dto.MinimumOrders;
			tier.MinimumDrinksPerOrder = dto.MinimumDrinksPerOrder;
			tier.DiscountPercentage = dto.DiscountPercentage;
			tier.MaxDiscountAmount = dto.MaxDiscountAmount;
			tier.Description = dto.Description;
			tier.LastUpdated = DateTime.UtcNow;
			tier.LastUpdatedBy = updatedBy;

			await _unitOfWork.DiscountTiers.UpdateAsync(tier);
			await _unitOfWork.SaveChangesAsync();

			return new ApiResponse
			{
				Success = true,
				Message = "Discount tier updated successfully"
			};
		}

		public async Task UpdateCustomerTierAsync(int userId)
		{
			var user = await _unitOfWork.Users.GetByIdAsync(userId);
			if (user == null) return;

			var eligibleTiers = await _unitOfWork.DiscountTiers.FindAsync(
				t => t.IsActive &&
					 t.MinimumOrders <= user.TotalCompletedOrders);

			var highestTier = eligibleTiers.OrderByDescending(t => t.TierLevel).FirstOrDefault();

			if (highestTier != null)
			{
				user.CurrentDiscountTier = highestTier.TierLevel;
				await _unitOfWork.Users.UpdateAsync(user);
				await _unitOfWork.SaveChangesAsync();
			}
		}
	}

}
