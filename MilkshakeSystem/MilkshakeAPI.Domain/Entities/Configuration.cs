using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
	public class Configuration
	{
		public int Id { get; set; }
		public string Key { get; set; } = string.Empty;
		public string Value { get; set; } = string.Empty;
		public string? Description { get; set; }
		public string? DataType { get; set; }

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? LastUpdated { get; set; }
		public int? LastUpdatedBy { get; set; }
	}

}
