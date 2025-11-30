using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface ILookupService
    {
        Task<List<LookupDto>> GetFlavoursAsync();
        Task<List<LookupDto>> GetToppingsAsync();
        Task<List<LookupDto>> GetConsistenciesAsync();
        Task<List<LookupDto>> GetAllLookupsAsync();
        Task<ApiResponse<LookupDto>> CreateLookupAsync(CreateLookupRequest request, int createdBy);
        Task<ApiResponse<LookupDto>> UpdateLookupAsync(int id, UpdateLookupRequest request, int updatedBy);
        Task<ApiResponse> DeleteLookupAsync(int id, int deletedBy);
    }

}
