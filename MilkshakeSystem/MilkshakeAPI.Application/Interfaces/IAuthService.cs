using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using MilkshakeAPI.Application.DTOs;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<bool> EmailExistsAsync(string email);
    }

}
