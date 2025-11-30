using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;


namespace MilkshakeAPI.Application.Interfaces
{
    public interface IRestaurantService
    {
        Task<List<RestaurantDto>> GetAllRestaurantsAsync();
        Task<RestaurantDto?> GetRestaurantByIdAsync(int id);
        Task<List<AvailableTimeSlot>> GetAvailableTimeSlotsAsync(int restaurantId, DateTime date);
        Task<ApiResponse<RestaurantDto>> CreateRestaurantAsync(CreateRestaurantRequest request, int createdBy);
        Task<ApiResponse<RestaurantDto>> UpdateRestaurantAsync(int id, CreateRestaurantRequest request, int updatedBy);
    }

}
