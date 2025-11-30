using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface IOrderService
    {
        Task<ApiResponse<OrderResponse>> CreateOrderAsync(CreateOrderRequest request);
        Task<ApiResponse<OrderResponse>> GetOrderByIdAsync(int orderId);
        Task<ApiResponse<List<OrderResponse>>> GetUserOrdersAsync(int userId);
        Task<ApiResponse<List<OrderResponse>>> GetAllOrdersAsync();
        Task<ApiResponse> UpdateOrderStatusAsync(int orderId, UpdateOrderStatusRequest request);
        Task<DashboardStats> GetDashboardStatsAsync();
        Task<List<TopSellerDto>> GetTopSellersAsync(int topCount = 5);
        Task<List<ActivityDto>> GetRecentActivityAsync(int count = 5);
    }

}
