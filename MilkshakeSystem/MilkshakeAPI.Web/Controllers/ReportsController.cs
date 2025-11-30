using Microsoft.AspNetCore.Mvc;
using MilkshakeAPI.Application.DTOs;
using MilkshakeAPI.Application.Interfaces;

namespace MilkshakeAPI.Web.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class ReportsController : ControllerBase
	{
		private readonly IReportService _reportService;

		public ReportsController(IReportService reportService)
		{
			_reportService = reportService;
		}

	
		[HttpPost("orders")]
		public async Task<ActionResult<PagedResult<OrderReportDto>>> GetOrdersReport([FromBody] ReportFilterRequest filter)
		{
			var result = await _reportService.GetOrdersReportAsync(filter);
			return Ok(result);
		}

		[HttpGet("trends/weekly")]
		public async Task<ActionResult<List<TrendDataDto>>> GetWeeklyTrends()
		{
			var trends = await _reportService.GetWeeklyTrendsAsync();
			return Ok(trends);
		}

	
		[HttpGet("trends/monthly")]
		public async Task<ActionResult<List<TrendDataDto>>> GetMonthlyTrends()
		{
			var trends = await _reportService.GetMonthlyTrendsAsync();
			return Ok(trends);
		}


		[HttpGet("trends/day-of-week")]
		public async Task<ActionResult<List<TrendDataDto>>> GetDayOfWeekAnalysis()
		{
			var analysis = await _reportService.GetDayOfWeekAnalysisAsync();
			return Ok(analysis);
		}


		[HttpPost("audit-trail")]
		public async Task<ActionResult<PagedResult<AuditLogDto>>> GetAuditTrail([FromBody] ReportFilterRequest filter)
		{
			var result = await _reportService.GetAuditTrailAsync(filter);
			return Ok(result);
		}
	}
}