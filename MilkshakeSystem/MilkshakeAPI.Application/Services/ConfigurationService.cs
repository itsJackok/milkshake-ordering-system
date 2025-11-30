using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Domain.Interfaces;

namespace MilkshakeAPI.Application.Services
{
	public class ConfigurationService : IConfigurationService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IAuditService _auditService;

		public ConfigurationService(IUnitOfWork unitOfWork, IAuditService auditService)
		{
			_unitOfWork = unitOfWork;
			_auditService = auditService;
		}

		public async Task<List<ConfigurationDto>> GetAllConfigurationsAsync()
		{
			var configs = await _unitOfWork.Configurations.GetAllAsync();

			return configs.Select(c => new ConfigurationDto
			{
				Id = c.Id,
				Key = c.Key,
				Value = c.Value,
				Description = c.Description,
				DataType = c.DataType,
				LastUpdated = c.LastUpdated
			}).OrderBy(c => c.Key).ToList();
		}

		public async Task<ConfigurationDto?> GetConfigurationByKeyAsync(string key)
		{
			var configs = await _unitOfWork.Configurations.FindAsync(c => c.Key == key);
			var config = configs.FirstOrDefault();

			if (config == null) return null;

			return new ConfigurationDto
			{
				Id = config.Id,
				Key = config.Key,
				Value = config.Value,
				Description = config.Description,
				DataType = config.DataType,
				LastUpdated = config.LastUpdated
			};
		}

		public async Task<string?> GetConfigValueAsync(string key)
		{
			var config = await GetConfigurationByKeyAsync(key);
			return config?.Value;
		}

		public async Task<int> GetIntConfigValueAsync(string key, int defaultValue = 0)
		{
			var value = await GetConfigValueAsync(key);
			if (string.IsNullOrEmpty(value)) return defaultValue;

			return int.TryParse(value, out var result) ? result : defaultValue;
		}

		public async Task<decimal> GetDecimalConfigValueAsync(string key, decimal defaultValue = 0)
		{
			var value = await GetConfigValueAsync(key);
			if (string.IsNullOrEmpty(value)) return defaultValue;

			return decimal.TryParse(value, out var result) ? result : defaultValue;
		}

		public async Task<ApiResponse> UpdateConfigurationAsync(
			string key, UpdateConfigurationRequest request, int updatedBy)
		{
			var configs = await _unitOfWork.Configurations.FindAsync(c => c.Key == key);
			var config = configs.FirstOrDefault();

			if (config == null)
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Configuration not found"
				};
			}

			// Validate based on data type
			if (config.DataType == "Integer" && !int.TryParse(request.Value, out _))
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Invalid integer value"
				};
			}

			if (config.DataType == "Decimal" && !decimal.TryParse(request.Value, out _))
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Invalid decimal value"
				};
			}

			// Log the change
			await _auditService.LogChangeAsync(
				updatedBy, "Configuration", config.Id, "Update",
				config.Key, config.Value, request.Value);

			// Update configuration
			config.Value = request.Value;
			config.LastUpdated = DateTime.UtcNow;
			config.LastUpdatedBy = updatedBy;

			await _unitOfWork.Configurations.UpdateAsync(config);
			await _unitOfWork.SaveChangesAsync();

			return new ApiResponse
			{
				Success = true,
				Message = "Configuration updated successfully"
			};
		}
	}
}
