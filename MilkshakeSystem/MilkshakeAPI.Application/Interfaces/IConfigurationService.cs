using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;


namespace MilkshakeAPI.Application.Interfaces
{
    public interface IConfigurationService
    {
        Task<List<ConfigurationDto>> GetAllConfigurationsAsync();
        Task<ConfigurationDto?> GetConfigurationByKeyAsync(string key);
        Task<string?> GetConfigValueAsync(string key);
        Task<int> GetIntConfigValueAsync(string key, int defaultValue = 0);
        Task<decimal> GetDecimalConfigValueAsync(string key, decimal defaultValue = 0);
        Task<ApiResponse> UpdateConfigurationAsync(string key, UpdateConfigurationRequest request, int updatedBy);
    }

}
