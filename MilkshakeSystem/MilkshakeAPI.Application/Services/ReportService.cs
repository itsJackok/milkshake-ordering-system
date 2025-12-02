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
	public class ReportService : IReportService
	{
		private readonly IUnitOfWork _unitOfWork;

		public ReportService(IUnitOfWork unitOfWork)
		{
			_unitOfWork = unitOfWork;
		}

		public async Task<PagedResult<OrderReportDto>> GetOrdersReportAsync(ReportFilterRequest filter)
		{
			var allOrders = await _unitOfWork.Orders.GetAllAsync();
			var query = allOrders.AsQueryable();

			if (filter.StartDate.HasValue)
			{
				query = query.Where(o => o.OrderDate.Date >= filter.StartDate.Value.Date);
			}

			if (filter.EndDate.HasValue)
			{
				query = query.Where(o => o.OrderDate.Date <= filter.EndDate.Value.Date);
			}

			if (!string.IsNullOrEmpty(filter.PaymentStatus))
			{
				query = query.Where(o => o.PaymentStatus == filter.PaymentStatus);
			}

			if (!string.IsNullOrEmpty(filter.OrderStatus))
			{
				query = query.Where(o => o.OrderStatus == filter.OrderStatus);
			}

			if (filter.RestaurantId.HasValue)
			{
				query = query.Where(o => o.RestaurantId == filter.RestaurantId.Value);
			}

			var totalRecords = query.Count();
			var totalPages = (int)Math.Ceiling(totalRecords / (double)filter.PageSize);
			var pagedOrders = query
				.OrderByDescending(o => o.OrderDate)
				.Skip((filter.PageNumber - 1) * filter.PageSize)
				.Take(filter.PageSize)
				.ToList();

			var reportData = new List<OrderReportDto>();

			foreach (var order in pagedOrders)
			{
				var user = await _unitOfWork.Users.GetByIdAsync(order.UserId);
				var restaurant = await _unitOfWork.Restaurants.GetByIdAsync(order.RestaurantId);
				var itemCount = (await _unitOfWork.OrderItems.FindAsync(oi => oi.OrderId == order.Id)).Count();

				reportData.Add(new OrderReportDto
				{
					Id = order.Id,
					OrderDate = order.OrderDate,
					Time = order.OrderDate.ToString("HH:mm"),
					CustomerName = user?.FullName ?? "",
					RestaurantName = restaurant?.Name ?? "",
					NumberOfDrinks = itemCount,
					TotalCost = order.TotalCost,
					PaymentStatus = order.PaymentStatus,
					OrderStatus = order.OrderStatus
				});
			}

			return new PagedResult<OrderReportDto>
			{
				Data = reportData,
				TotalRecords = totalRecords,
				PageNumber = filter.PageNumber,
				PageSize = filter.PageSize,
				TotalPages = totalPages
			};
		}

		public async Task<List<TrendDataDto>> GetWeeklyTrendsAsync()
		{
			var today = DateTime.Today;
			var sevenDaysAgo = today.AddDays(-6);

			var orders = (await _unitOfWork.Orders.GetAllAsync())
				.Where(o => o.OrderDate.Date >= sevenDaysAgo && o.OrderDate.Date <= today)
				.ToList();

			var trends = new List<TrendDataDto>();

			for (int i = 6; i >= 0; i--)
			{
				var date = today.AddDays(-i);
				var dayOrders = orders.Where(o => o.OrderDate.Date == date).ToList();

				trends.Add(new TrendDataDto
				{
					Label = date.ToString("ddd"),
					OrderCount = dayOrders.Count,
					Revenue = dayOrders.Where(o => o.PaymentStatus == "Paid").Sum(o => o.TotalCost)
				});
			}

			return trends;
		}

		public async Task<List<TrendDataDto>> GetMonthlyTrendsAsync()
		{
			var currentYear = DateTime.Now.Year;
			var allOrders = (await _unitOfWork.Orders.GetAllAsync())
				.Where(o => o.OrderDate.Year == currentYear)
				.ToList();

			var trends = new List<TrendDataDto>();
			var monthNames = new[] { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
									"Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

			for (int month = 1; month <= 12; month++)
			{
				var monthOrders = allOrders.Where(o => o.OrderDate.Month == month).ToList();

				trends.Add(new TrendDataDto
				{
					Label = monthNames[month - 1],
					OrderCount = monthOrders.Count,
					Revenue = monthOrders.Where(o => o.PaymentStatus == "Paid").Sum(o => o.TotalCost)
				});
			}

			return trends;
		}

		public async Task<List<TrendDataDto>> GetDayOfWeekAnalysisAsync()
		{
			var fourWeeksAgo = DateTime.Today.AddDays(-28);
			var orders = (await _unitOfWork.Orders.GetAllAsync())
				.Where(o => o.OrderDate.Date >= fourWeeksAgo)
				.ToList();

			var dayOfWeekTrends = new List<TrendDataDto>();
			var dayNames = new[] { "Sunday", "Monday", "Tuesday", "Wednesday",
								  "Thursday", "Friday", "Saturday" };

			for (int day = 0; day < 7; day++)
			{
				var dayOrders = orders.Where(o => (int)o.OrderDate.DayOfWeek == day).ToList();

				dayOfWeekTrends.Add(new TrendDataDto
				{
					Label = dayNames[day],
					OrderCount = dayOrders.Count,
					Revenue = dayOrders.Where(o => o.PaymentStatus == "Paid").Sum(o => o.TotalCost)
				});
			}

			return dayOfWeekTrends;
		}

		public async Task<PagedResult<AuditLogDto>> GetAuditTrailAsync(ReportFilterRequest filter)
		{
			var allAuditLogs = await _unitOfWork.AuditLogs.GetAllAsync();
			var query = allAuditLogs.AsQueryable();

			if (filter.StartDate.HasValue)
			{
				query = query.Where(a => a.Timestamp.Date >= filter.StartDate.Value.Date);
			}

			if (filter.EndDate.HasValue)
			{
				query = query.Where(a => a.Timestamp.Date <= filter.EndDate.Value.Date);
			}

			var totalRecords = query.Count();
			var totalPages = (int)Math.Ceiling(totalRecords / (double)filter.PageSize);

			var pagedLogs = query
				.OrderByDescending(a => a.Timestamp)
				.Skip((filter.PageNumber - 1) * filter.PageSize)
				.Take(filter.PageSize)
				.ToList();

			var auditData = new List<AuditLogDto>();

			foreach (var log in pagedLogs)
			{
				var user = await _unitOfWork.Users.GetByIdAsync(log.UserId);

				auditData.Add(new AuditLogDto
				{
					Id = log.Id,
					UserName = user?.FullName ?? "System",
					EntityType = log.EntityType,
					EntityId = log.EntityId,
					Action = log.Action,
					FieldChanged = log.FieldChanged,
					OldValue = log.OldValue,
					NewValue = log.NewValue,
					Timestamp = log.Timestamp
				});
			}

			return new PagedResult<AuditLogDto>
			{
				Data = auditData,
				TotalRecords = totalRecords,
				PageNumber = filter.PageNumber,
				PageSize = filter.PageSize,
				TotalPages = totalPages
			};
		}
	}

}
