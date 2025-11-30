using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class RestaurantDto
	{
		public int Id { get; set; }
		public string Name { get; set; } = string.Empty;
		public string Address { get; set; } = string.Empty;
		public string? PhoneNumber { get; set; }
		public TimeSpan OpeningTime { get; set; }
		public TimeSpan ClosingTime { get; set; }
		public bool IsActive { get; set; }
	}

	public class CreateRestaurantRequest
	{
		public string Name { get; set; } = string.Empty;
		public string Address { get; set; } = string.Empty;
		public string? PhoneNumber { get; set; }
		public TimeSpan OpeningTime { get; set; }
		public TimeSpan ClosingTime { get; set; }
	}

	public class AvailableTimeSlot
	{
		public DateTime Time { get; set; }
		public string DisplayTime { get; set; } = string.Empty;
		public bool IsAvailable { get; set; }
	}

}
