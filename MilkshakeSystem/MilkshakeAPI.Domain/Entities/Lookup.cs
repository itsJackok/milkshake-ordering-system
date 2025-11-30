using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
		public class Lookup
	{
		public int Id { get; set; }
		public string Name { get; set; } = string.Empty;
		public string Type { get; set; } = string.Empty;
		public decimal Price { get; set; } = 0;
		public string? Description { get; set; }
		public bool IsActive { get; set; } = true;

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? LastUpdated { get; set; }
		public int? LastUpdatedBy { get; set; }
		public string? LastAction { get; set; }
	}

}
