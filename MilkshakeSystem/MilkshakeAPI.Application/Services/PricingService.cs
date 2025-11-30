using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Domain.Interfaces;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.Services
{

	
		public class PricingService : IPricingService
		{
			private readonly IUnitOfWork _unitOfWork;
			private readonly IConfigurationService _configService;

			public PricingService(IUnitOfWork unitOfWork, IConfigurationService configService)
			{
				_unitOfWork = unitOfWork;
				_configService = configService;
			}

			public async Task<decimal> CalculateDrinkPriceAsync(int flavourId, int toppingId, int consistencyId)
			{
				var flavour = await _unitOfWork.Lookups.GetByIdAsync(flavourId);
				var topping = await _unitOfWork.Lookups.GetByIdAsync(toppingId);
				var consistency = await _unitOfWork.Lookups.GetByIdAsync(consistencyId);

				if (flavour == null || topping == null || consistency == null)
				{
					throw new Exception("Invalid lookup IDs");
				}

				return flavour.Price + topping.Price + consistency.Price;
			}

			public async Task<decimal> CalculateOrderSubtotalAsync(List<OrderItemRequest> items)
			{
				decimal subtotal = 0;

				foreach (var item in items)
				{
					var drinkPrice = await CalculateDrinkPriceAsync(
						item.FlavourId,
						item.ToppingId,
						item.ConsistencyId);

					subtotal += drinkPrice;
				}

				return subtotal;
			}

			public async Task<decimal> CalculateVATAsync(decimal subtotal)
			{
				var vatPercentage = await _configService.GetDecimalConfigValueAsync("VATPercentage", 15);
				return subtotal * (vatPercentage / 100);
			}

			public decimal GetVATPercentage()
			{
				// This will be called synchronously, so we use a default
				// The actual VAT will be calculated async in CalculateVATAsync
				return 15m;
			}
		}
	
}
