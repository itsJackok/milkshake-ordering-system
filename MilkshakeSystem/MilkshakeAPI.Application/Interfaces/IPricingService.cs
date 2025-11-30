using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface IPricingService
    {
        Task<decimal> CalculateDrinkPriceAsync(int flavourId, int toppingId, int consistencyId);
        Task<decimal> CalculateOrderSubtotalAsync(List<OrderItemRequest> items);
        Task<decimal> CalculateVATAsync(decimal subtotal);
        decimal GetVATPercentage();
    }

}
