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
	public class LookupService : ILookupService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IAuditService _auditService;

		public LookupService(IUnitOfWork unitOfWork, IAuditService auditService)
		{
			_unitOfWork = unitOfWork;
			_auditService = auditService;
		}

		public async Task<List<LookupDto>> GetFlavoursAsync()
		{
			var flavours = await _unitOfWork.Lookups.FindAsync(l => l.Type == "Flavour" && l.IsActive);
			return MapToDto(flavours);
		}

		public async Task<List<LookupDto>> GetToppingsAsync()
		{
			var toppings = await _unitOfWork.Lookups.FindAsync(l => l.Type == "Topping" && l.IsActive);
			return MapToDto(toppings);
		}

		public async Task<List<LookupDto>> GetConsistenciesAsync()
		{
			var consistencies = await _unitOfWork.Lookups.FindAsync(l => l.Type == "Consistency" && l.IsActive);
			return MapToDto(consistencies);
		}

		public async Task<List<LookupDto>> GetAllLookupsAsync()
		{
			var lookups = await _unitOfWork.Lookups.FindAsync(l => l.IsActive);
			return MapToDto(lookups);
		}

		public async Task<ApiResponse<LookupDto>> CreateLookupAsync(CreateLookupRequest request, int createdBy)
		{
			// Validate type
			if (request.Type != "Flavour" && request.Type != "Topping" && request.Type != "Consistency")
			{
				return new ApiResponse<LookupDto>
				{
					Success = false,
					Message = "Invalid lookup type. Must be Flavour, Topping, or Consistency"
				};
			}

			// Check for duplicate name within type
			var existing = await _unitOfWork.Lookups.FindAsync(
				l => l.Name == request.Name && l.Type == request.Type && l.IsActive);

			if (existing.Any())
			{
				return new ApiResponse<LookupDto>
				{
					Success = false,
					Message = $"A {request.Type} with this name already exists"
				};
			}

			var lookup = new Lookup
			{
				Name = request.Name,
				Type = request.Type,
				Price = request.Price,
				Description = request.Description,
				IsActive = true,
				CreatedAt = DateTime.UtcNow,
				LastUpdatedBy = createdBy,
				LastAction = "Created"
			};

			await _unitOfWork.Lookups.AddAsync(lookup);
			await _unitOfWork.SaveChangesAsync();

			// Log creation
			await _auditService.LogChangeAsync(
				createdBy,
				"Lookup",
				lookup.Id,
				"Create",
				null,
				null,
				$"Created {request.Type}: {request.Name} at R{request.Price}");

			return new ApiResponse<LookupDto>
			{
				Success = true,
				Message = "Lookup created successfully",
				Data = new LookupDto
				{
					Id = lookup.Id,
					Name = lookup.Name,
					Type = lookup.Type,
					Price = lookup.Price,
					Description = lookup.Description,
					IsActive = lookup.IsActive,
					LastUpdated = lookup.LastUpdated
				}
			};
		}

		public async Task<ApiResponse<LookupDto>> UpdateLookupAsync(int id, UpdateLookupRequest request, int updatedBy)
		{
			var lookup = await _unitOfWork.Lookups.GetByIdAsync(id);
			if (lookup == null || !lookup.IsActive)
			{
				return new ApiResponse<LookupDto>
				{
					Success = false,
					Message = "Lookup not found"
				};
			}

			// Log changes
			if (lookup.Name != request.Name)
			{
				await _auditService.LogChangeAsync(
					updatedBy, "Lookup", id, "Update", "Name", lookup.Name, request.Name);
			}

			if (lookup.Price != request.Price)
			{
				await _auditService.LogChangeAsync(
					updatedBy, "Lookup", id, "Update", "Price",
					lookup.Price.ToString(), request.Price.ToString());
			}

			if (lookup.Description != request.Description)
			{
				await _auditService.LogChangeAsync(
					updatedBy, "Lookup", id, "Update", "Description",
					lookup.Description ?? "", request.Description ?? "");
			}

			// Update lookup
			lookup.Name = request.Name;
			lookup.Price = request.Price;
			lookup.Description = request.Description;
			lookup.LastUpdated = DateTime.UtcNow;
			lookup.LastUpdatedBy = updatedBy;
			lookup.LastAction = "Updated";

			await _unitOfWork.Lookups.UpdateAsync(lookup);
			await _unitOfWork.SaveChangesAsync();

			return new ApiResponse<LookupDto>
			{
				Success = true,
				Message = "Lookup updated successfully",
				Data = new LookupDto
				{
					Id = lookup.Id,
					Name = lookup.Name,
					Type = lookup.Type,
					Price = lookup.Price,
					Description = lookup.Description,
					IsActive = lookup.IsActive,
					LastUpdated = lookup.LastUpdated
				}
			};
		}

		public async Task<ApiResponse> DeleteLookupAsync(int id, int deletedBy)
		{
			var lookup = await _unitOfWork.Lookups.GetByIdAsync(id);
			if (lookup == null)
			{
				return new ApiResponse
				{
					Success = false,
					Message = "Lookup not found"
				};
			}

			// Soft delete
			lookup.IsActive = false;
			lookup.LastUpdated = DateTime.UtcNow;
			lookup.LastUpdatedBy = deletedBy;
			lookup.LastAction = "Deleted";

			await _unitOfWork.Lookups.UpdateAsync(lookup);
			await _unitOfWork.SaveChangesAsync();

			// Log deletion
			await _auditService.LogChangeAsync(
				deletedBy, "Lookup", id, "Delete", null, null,
				$"Deleted {lookup.Type}: {lookup.Name}");

			return new ApiResponse
			{
				Success = true,
				Message = "Lookup deleted successfully"
			};
		}

		private List<LookupDto> MapToDto(IEnumerable<Lookup> lookups)
		{
			return lookups.Select(l => new LookupDto
			{
				Id = l.Id,
				Name = l.Name,
				Type = l.Type,
				Price = l.Price,
				Description = l.Description,
				IsActive = l.IsActive,
				LastUpdated = l.LastUpdated
			}).OrderBy(l => l.Name).ToList();
		}
	}

}
