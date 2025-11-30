using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface IDiscountService
    {
        Task<CalculateDiscountResponse> CalculateDiscountAsync(CalculateDiscountRequest request);
        Task<CustomerDiscountInfo> GetCustomerDiscountInfoAsync(int userId);
        Task<List<DiscountTierDto>> GetAllDiscountTiersAsync();
        Task<ApiResponse> UpdateDiscountTierAsync(int tierId, DiscountTierDto dto, int updatedBy);
        Task UpdateCustomerTierAsync(int userId);
    }

}
