using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Application.DTOs;

namespace MilkshakeAPI.Application.Interfaces
{
    public interface IReportService
    {
        Task<PagedResult<OrderReportDto>> GetOrdersReportAsync(ReportFilterRequest filter);
        Task<List<TrendDataDto>> GetWeeklyTrendsAsync();
        Task<List<TrendDataDto>> GetMonthlyTrendsAsync();
        Task<List<TrendDataDto>> GetDayOfWeekAnalysisAsync();
        Task<PagedResult<AuditLogDto>> GetAuditTrailAsync(ReportFilterRequest filter);
    }

}
