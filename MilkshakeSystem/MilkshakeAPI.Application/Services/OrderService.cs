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
	public class OrderService : IOrderService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IPricingService _pricingService;
		private readonly IDiscountService _discountService;

		public OrderService(
			IUnitOfWork unitOfWork,
			IPricingService pricingService,
			IDiscountService discountService)
		{
			_unitOfWork = unitOfWork;
			_pricingService = pricingService;
			_discountService = discountService;
		}

		public async Task<ApiResponse<OrderResponse>> CreateOrderAsync(CreateOrderRequest request)
		{
			try
			{
				// Validate user
				var user = await _unitOfWork.Users.GetByIdAsync(request.UserId);
				if (user == null)
				{
					return new ApiResponse<OrderResponse>
					{
						Success = false,
						Message = "User not found"
					};
				}

				// Validate restaurant
				var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(request.RestaurantId);
				if (restaurant == null || !restaurant.IsActive)
				{
					return new ApiResponse<OrderResponse>
					{
						Success = false,
						Message = "Restaurant not found or inactive"
					};
				}

				// Validate pickup time
				if (request.PickupTime <= DateTime.Now)
				{
					return new ApiResponse<OrderResponse>
					{
						Success = false,
						Message = "Pickup time must be in the future"
					};
				}

				// Calculate subtotal
				var subtotal = await _pricingService.CalculateOrderSubtotalAsync(request.Items);

				// Calculate VAT
				var vat = await _pricingService.CalculateVATAsync(subtotal);

				// Calculate discount
				var discountRequest = new CalculateDiscountRequest
				{
					UserId = request.UserId,
					OrderSubtotal = subtotal,
					NumberOfDrinks = request.Items.Count
				};
				var discount = await _discountService.CalculateDiscountAsync(discountRequest);

				// Calculate total
				var totalCost = subtotal + vat - discount.ActualDiscount;

				// Create order
				var order = new Order
				{
					UserId = request.UserId,
					RestaurantId = request.RestaurantId,
					OrderDate = DateTime.UtcNow,
					PickupTime = request.PickupTime,
					Subtotal = subtotal,
					VAT = vat,
					DiscountAmount = discount.ActualDiscount,
					DiscountTierApplied = discount.TierApplied,
					TotalCost = totalCost,
					PaymentStatus = "Pending",
					OrderStatus = "Pending"
				};

				await _unitOfWork.Orders.AddAsync(order);
				await _unitOfWork.SaveChangesAsync();

				// Create order items
				foreach (var item in request.Items)
				{
					var flavour = await _unitOfWork.Lookups.GetByIdAsync(item.FlavourId);
					var topping = await _unitOfWork.Lookups.GetByIdAsync(item.ToppingId);
					var consistency = await _unitOfWork.Lookups.GetByIdAsync(item.ConsistencyId);

					var orderItem = new OrderItem
					{
						OrderId = order.Id,
						FlavourId = item.FlavourId,
						ToppingId = item.ToppingId,
						ConsistencyId = item.ConsistencyId,
						FlavourPrice = flavour!.Price,
						ToppingPrice = topping!.Price,
						ConsistencyPrice = consistency!.Price,
						ItemTotal = flavour.Price + topping.Price + consistency.Price
					};

					await _unitOfWork.OrderItems.AddAsync(orderItem);
				}

				await _unitOfWork.SaveChangesAsync();

				// Return response
				return new ApiResponse<OrderResponse>
				{
					Success = true,
					Message = "Order created successfully",
					Data = await GetOrderByIdAsync(order.Id).ContinueWith(t => t.Result.Data!)
				};
			}
			catch (Exception ex)
			{
				return new ApiResponse<OrderResponse>
				{
					Success = false,
					Message = "Failed to create order",
					Errors = new List<string> { ex.Message }
				};
			}
		}

		public async Task<ApiResponse<OrderResponse>> GetOrderByIdAsync(int orderId)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(orderId);
			if (order == null)
			{
				return new ApiResponse<OrderResponse>
				{
					Success = false,
					Message = "Order not found"
				};
			}

			var orderItems = await _unitOfWork.OrderItems.FindAsync(oi => oi.OrderId == orderId);
			var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);
			var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(order.RestaurantId);

			// Get discount tier name
			string tierName = "None";
			if (order.DiscountTierApplied > 0)
			{
				var tiers = await _unitOfWork.DiscountTiers.FindAsync(
					t => t.TierLevel == order.DiscountTierApplied);
				tierName = tiers.FirstOrDefault()?.TierName ?? "None";
			}

			var response = new OrderResponse
			{
				Id = order.Id,
				OrderDate = order.OrderDate,
				PickupTime = order.PickupTime,
				UserName = user?.FullName ?? "",
				UserEmail = user?.Email ?? "",
				RestaurantName = restaurant?.Name ?? "",
				RestaurantAddress = restaurant?.Address ?? "",
				Subtotal = order.Subtotal,
				VAT = order.VAT,
				VATPercentage = _pricingService.GetVATPercentage(),
				DiscountAmount = order.DiscountAmount,
				DiscountTierApplied = order.DiscountTierApplied,
				DiscountTierName = tierName,
				TotalCost = order.TotalCost,
				PaymentStatus = order.PaymentStatus,
				OrderStatus = order.OrderStatus,
				NumberOfDrinks = orderItems.Count(),
				Items = new List<OrderItemResponse>()
			};

			foreach (var item in orderItems)
			{
				var flavour = await _unitOfWork.Lookups.GetByIdAsync(item.FlavourId);
				var topping = await _unitOfWork.Lookups.GetByIdAsync(item.ToppingId);
				var consistency = await _unitOfWork.Lookups.GetByIdAsync(item.ConsistencyId);

				response.Items.Add(new OrderItemResponse
				{
					Id = item.Id,
					FlavourName = flavour?.Name ?? "",
					ToppingName = topping?.Name ?? "",
					ConsistencyName = consistency?.Name ?? "",
					FlavourPrice = item.FlavourPrice,
					ToppingPrice = item.ToppingPrice,
					ConsistencyPrice = item.ConsistencyPrice,
					ItemTotal = item.ItemTotal
				});
			}

			return new ApiResponse<OrderResponse>
			{
				Success = true,
				Data = response
			};
		}

		public async Task<ApiResponse<List<OrderResponse>>> GetUserOrdersAsync(int userId)
		{
			var orders = await _unitOfWork.Orders.FindAsync(o => o.UserId == userId);
			var orderList = new List<OrderResponse>();

			foreach (var order in orders.OrderByDescending(o => o.OrderDate))
			{
				var orderResponse = await GetOrderByIdAsync(order.Id);
				if (orderResponse.Success && orderResponse.Data != null)
				{
					orderList.Add(orderResponse.Data);
				}
			}

			return new ApiResponse<List<OrderResponse>>
			{
				Success = true,
				Data = orderList
			};
		}

		public async Task<ApiResponse<List<OrderResponse>>> GetAllOrdersAsync()
		{
			var orders = await _unitOfWork.Orders.GetAllAsync();
			var orderList = new List<OrderResponse>();

			foreach (var order in orders.OrderByDescending(o => o.OrderDate))
			{
				var orderResponse = await GetOrderByIdAsync(order.Id);
				if (orderResponse.Success && orderResponse.Data != null)
				{
					orderList.Add(orderResponse.Data);
				}
			}

			return new ApiResponse<List<OrderResponse>>
			{
				Success = true,
				Data = orderList
			};
		}

		public async Task<ApiResponse> UpdateOrderStatusAsync(int orderId, UpdateOrderStatusRequest request)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(orderId);
			if (order == null)
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Order not found"
				};
			}

			order.OrderStatus = request.OrderStatus;
			if (!string.IsNullOrEmpty(request.PaymentStatus))
			{
				order.PaymentStatus = request.PaymentStatus;
			}

			if (request.OrderStatus == "Completed")
			{
				order.CompletedAt = DateTime.UtcNow;

				// Update customer statistics
				var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);
				if (user != null)
				{
					user.TotalCompletedOrders++;
					var orderItems = await _unitOfWork.OrderItems.FindAsync(oi => oi.OrderId == orderId);
					user.TotalDrinksPurchased += orderItems.Count();

					await _unitOfWork.Users.UpdateAsync(user);
					await _discountService.UpdateCustomerTierAsync(user.Id);
				}
			}

			if (request.OrderStatus == "Cancelled")
			{
				order.CancelledAt = DateTime.UtcNow;
			}

			order.UpdatedAt = DateTime.UtcNow;
			await _unitOfWork.Orders.UpdateAsync(order);
			await _unitOfWork.SaveChangesAsync();

			return new ApiResponse
			{
				Success = true,
				Message = "Order status updated successfully"
			};
		}

		public async Task<DashboardStats> GetDashboardStatsAsync()
		{
			var today = DateTime.Today;
			var yesterday = today.AddDays(-1);

			var allOrders = await _unitOfWork.Orders.GetAllAsync();

			// Today's orders
			var todayOrders = allOrders.Where(o => o.OrderDate.Date == today).ToList();
			var yesterdayOrders = allOrders.Where(o => o.OrderDate.Date == yesterday).ToList();

			// Today's revenue (only paid orders)
			var todayRevenue = todayOrders
				.Where(o => o.PaymentStatus == "Paid")
				.Sum(o => o.TotalCost);

			var yesterdayRevenue = yesterdayOrders
				.Where(o => o.PaymentStatus == "Paid")
				.Sum(o => o.TotalCost);

			// Calculate percentage changes
			int ordersChange = yesterdayOrders.Count > 0
				? (int)((todayOrders.Count - yesterdayOrders.Count) / (decimal)yesterdayOrders.Count * 100)
				: 0;

			decimal revenueChange = yesterdayRevenue > 0
				? ((todayRevenue - yesterdayRevenue) / yesterdayRevenue * 100)
				: 0;

			// Popular flavour today
			var todayOrderIds = todayOrders.Select(o => o.Id).ToList();
			var todayItems = (await _unitOfWork.OrderItems.GetAllAsync())
				.Where(oi => todayOrderIds.Contains(oi.OrderId))
				.ToList();

			var popularFlavour = todayItems
				.GroupBy(oi => oi.FlavourId)
				.OrderByDescending(g => g.Count())
				.FirstOrDefault();

			string popularFlavourName = "";
			int popularFlavourCount = 0;

			if (popularFlavour != null)
			{
				var flavour = await _unitOfWork.Lookups.GetByIdAsync(popularFlavour.Key);
				popularFlavourName = flavour?.Name ?? "";
				popularFlavourCount = popularFlavour.Count();
			}

			// Pending orders
			var pendingOrders = allOrders.Count(o => o.OrderStatus == "Pending");

			return new DashboardStats
			{
				TodayOrders = todayOrders.Count,
				TodayOrdersChange = ordersChange,
				TodayRevenue = todayRevenue,
				TodayRevenueChange = revenueChange,
				PopularFlavour = popularFlavourName,
				PopularFlavourCount = popularFlavourCount,
				PendingOrders = pendingOrders
			};
		}

		public async Task<List<TopSellerDto>> GetTopSellersAsync(int topCount = 5)
		{
			var today = DateTime.Today;
			var todayOrders = (await _unitOfWork.Orders.GetAllAsync())
				.Where(o => o.OrderDate.Date == today)
				.Select(o => o.Id)
				.ToList();

			var todayItems = (await _unitOfWork.OrderItems.GetAllAsync())
				.Where(oi => todayOrders.Contains(oi.OrderId))
				.ToList();

			var totalItems = todayItems.Count;
			if (totalItems == 0) return new List<TopSellerDto>();

			var topSellers = todayItems
				.GroupBy(oi => oi.FlavourId)
				.Select(g => new
				{
					FlavourId = g.Key,
					Count = g.Count(),
					Percentage = (decimal)g.Count() / totalItems * 100
				})
				.OrderByDescending(x => x.Count)
				.Take(topCount)
				.ToList();

			var result = new List<TopSellerDto>();
			foreach (var seller in topSellers)
			{
				var flavour = await _unitOfWork.Lookups.GetByIdAsync(seller.FlavourId);
				result.Add(new TopSellerDto
				{
					Name = flavour?.Name ?? "",
					OrderCount = seller.Count,
					Percentage = seller.Percentage
				});
			}

			return result;
		}

		public async Task<List<ActivityDto>> GetRecentActivityAsync(int count = 5)
		{
			var recentOrders = (await _unitOfWork.Orders.GetAllAsync())
				.OrderByDescending(o => o.UpdatedAt)
				.Take(count)
				.ToList();

			var activities = new List<ActivityDto>();

			foreach (var order in recentOrders)
			{
				var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);

				string type, title, subtitle, icon, color;

				if (order.OrderStatus == "Completed")
				{
					type = "completion";
					title = "Order Completed";
					subtitle = $"{user?.FullName} - Order #{order.Id}";
					icon = "check_circle";
					color = "green";
				}
				else if (order.OrderStatus == "Cancelled")
				{
					type = "cancellation";
					title = "Order Cancelled";
					subtitle = $"{user?.FullName} - Order #{order.Id}";
					icon = "cancel";
					color = "red";
				}
				else if (order.PaymentStatus == "Paid")
				{
					type = "payment";
					title = "Payment Received";
					subtitle = $"{user?.FullName} - R{order.TotalCost:F2}";
					icon = "payment";
					color = "blue";
				}
				else
				{
					type = "order";
					title = "New Order";
					subtitle = $"{user?.FullName} - {order.OrderItems?.Count ?? 0} drinks";
					icon = "shopping_cart";
					color = "orange";
				}

				activities.Add(new ActivityDto
				{
					Type = type,
					Title = title,
					Subtitle = subtitle,
					Timestamp = order.UpdatedAt,
					Icon = icon,
					Color = color
				});
			}

			return activities;
		}
	}


}
