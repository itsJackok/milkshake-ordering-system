using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
	public class AuditLog
	{
		public int Id { get; set; }
		public int UserId { get; set; }
		public User? User { get; set; }

		public string EntityType { get; set; } = string.Empty;
		public int EntityId { get; set; }
		public string Action { get; set; } = string.Empty;
		public string? FieldChanged { get; set; }
		public string? OldValue { get; set; }
		public string? NewValue { get; set; }
		public string? IPAddress { get; set; }
		public DateTime Timestamp { get; set; } = DateTime.UtcNow;
		public string? AdditionalInfo { get; set; }
	}

}
