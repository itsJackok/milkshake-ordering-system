using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Application.DTOs
{
	public class LookupDto
	{
		public int Id { get; set; }
		public string Name { get; set; } = string.Empty;
		public string Type { get; set; } = string.Empty;
		public decimal Price { get; set; }
		public string? Description { get; set; }
		public bool IsActive { get; set; }
		public DateTime? LastUpdated { get; set; }
	}

	public class CreateLookupRequest
	{
		public string Name { get; set; } = string.Empty;
		public string Type { get; set; } = string.Empty;
		public decimal Price { get; set; }
		public string? Description { get; set; }
	}

	public class UpdateLookupRequest
	{
		public string Name { get; set; } = string.Empty;
		public decimal Price { get; set; }
		public string? Description { get; set; }
	}
}
