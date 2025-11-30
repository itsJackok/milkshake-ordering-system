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
	public class RestaurantService : IRestaurantService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IAuditService _auditService;

		public RestaurantService(IUnitOfWork unitOfWork, IAuditService auditService)
		{
			_unitOfWork = unitOfWork;
			_auditService = auditService;
		}

		public async Task<List<RestaurantDto>> GetAllRestaurantsAsync()
		{
			var restaurants = await _unitOfWork.Restaurants.FindAsync(r => r.IsActive);

			return restaurants.Select(r => new RestaurantDto
			{
				Id = r.Id,
				Name = r.Name,
				Address = r.Address,
				PhoneNumber = r.PhoneNumber,
				OpeningTime = r.OpeningTime,
				ClosingTime = r.ClosingTime,
				IsActive = r.IsActive
			}).OrderBy(r => r.Name).ToList();
		}

		public async Task<RestaurantDto?> GetRestaurantByIdAsync(int id)
		{
			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(id);
			if (restaurant == null) return null;

			return new RestaurantDto
			{
				Id = restaurant.Id,
				Name = restaurant.Name,
				Address = restaurant.Address,
				PhoneNumber = restaurant.PhoneNumber,
				OpeningTime = restaurant.OpeningTime,
				ClosingTime = restaurant.ClosingTime,
				IsActive = restaurant.IsActive
			};
		}

		public async Task<List<AvailableTimeSlot>> GetAvailableTimeSlotsAsync(int restaurantId, DateTime date)
		{
			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(restaurantId);
			if (restaurant == null || !restaurant.IsActive)
			{
				return new List<AvailableTimeSlot>();
			}

			var slots = new List<AvailableTimeSlot>();
			var now = DateTime.Now;

			// Start from opening time or current time (whichever is later)
			var startTime = date.Date.Add(restaurant.OpeningTime);
			if (date.Date == now.Date && now > startTime)
			{
				// Round up to next 15-minute slot
				var minutes = now.Minute;
				var roundedMinutes = ((minutes + 14) / 15) * 15;
				startTime = now.Date.AddHours(now.Hour).AddMinutes(roundedMinutes);

				// Add 15 minutes buffer for preparation
				startTime = startTime.AddMinutes(15);
			}

			var endTime = date.Date.Add(restaurant.ClosingTime);

			// Generate 15-minute intervals
			var currentSlot = startTime;
			while (currentSlot < endTime)
			{
				// Check if slot is available (not fully booked)
				var ordersAtTime = (await _unitOfWork.Orders.FindAsync(
					o => o.RestaurantId == restaurantId &&
						 o.PickupTime >= currentSlot &&
						 o.PickupTime < currentSlot.AddMinutes(15) &&
						 o.OrderStatus != "Cancelled"))
					.Count();

				// Allow max 5 orders per 15-min slot
				var isAvailable = ordersAtTime < 5;

				slots.Add(new AvailableTimeSlot
				{
					Time = currentSlot,
					DisplayTime = currentSlot.ToString("HH:mm"),
					IsAvailable = isAvailable
				});

				currentSlot = currentSlot.AddMinutes(15);
			}

			return slots;
		}

		public async Task<ApiResponse<RestaurantDto>> CreateRestaurantAsync(CreateRestaurantRequest request, int createdBy)
		{
			// Validate times
			if (request.OpeningTime >= request.ClosingTime)
			{
				return new ApiResponse<RestaurantDto>
				{
					Success = false,
					Message = "Opening time must be before closing time"
				};
			}

			var restaurant = new Restaurant
			{
				Name = request.Name,
				Address = request.Address,
				PhoneNumber = request.PhoneNumber,
				OpeningTime = request.OpeningTime,
				ClosingTime = request.ClosingTime,
				IsActive = true,
				CreatedAt = DateTime.UtcNow,
				LastUpdatedBy = createdBy
			};

			await _unitOfWork.Restaurants.AddAsync(restaurant);
			await _unitOfWork.SaveChangesAsync();

			// Log creation
			await _auditService.LogChangeAsync(
				createdBy, "Restaurant", restaurant.Id, "Create", null, null,
				$"Created restaurant: {request.Name}");

			return new ApiResponse<RestaurantDto>
			{
				Success = true,
				Message = "Restaurant created successfully",
				Data = new RestaurantDto
				{
					Id = restaurant.Id,
					Name = restaurant.Name,
					Address = restaurant.Address,
					PhoneNumber = restaurant.PhoneNumber,
					OpeningTime = restaurant.OpeningTime,
					ClosingTime = restaurant.ClosingTime,
					IsActive = restaurant.IsActive
				}
			};
		}

		public async Task<ApiResponse<RestaurantDto>> UpdateRestaurantAsync(
			int id, CreateRestaurantRequest request, int updatedBy)
		{
			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(id);
			if (restaurant == null)
			{
				return new ApiResponse<RestaurantDto>
				{
					Success = false,
					Message = "Restaurant not found"
				};
			}

			// Validate times
			if (request.OpeningTime >= request.ClosingTime)
			{
				return new ApiResponse<RestaurantDto>
				{
					Success = false,
					Message = "Opening time must be before closing time"
				};
			}

			// Log changes
			if (restaurant.Name != request.Name)
			{
				await _auditService.LogChangeAsync(
					updatedBy, "Restaurant", id, "Update", "Name",
					restaurant.Name, request.Name);
			}

			if (restaurant.Address != request.Address)
			{
				await _auditService.LogChangeAsync(
					updatedBy, "Restaurant", id, "Update", "Address",
					restaurant.Address, request.Address);
			}

			// Update restaurant
			restaurant.Name = request.Name;
			restaurant.Address = request.Address;
			restaurant.PhoneNumber = request.PhoneNumber;
			restaurant.OpeningTime = request.OpeningTime;
			restaurant.ClosingTime = request.ClosingTime;
			restaurant.LastUpdated = DateTime.UtcNow;
			restaurant.LastUpdatedBy = updatedBy;

			await _unitOfWork.Restaurants.UpdateAsync(restaurant);
			await _unitOfWork.SaveChangesAsync();

			return new ApiResponse<RestaurantDto>
			{
				Success = true,
				Message = "Restaurant updated successfully",
				Data = new RestaurantDto
				{
					Id = restaurant.Id,
					Name = restaurant.Name,
					Address = restaurant.Address,
					PhoneNumber = restaurant.PhoneNumber,
					OpeningTime = restaurant.OpeningTime,
					ClosingTime = restaurant.ClosingTime,
					IsActive = restaurant.IsActive
				}
			};
		}
	}
}
