using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{
	public class EmailLog
	{
		public int Id { get; set; }
		public int? UserId { get; set; }
		public User? User { get; set; }
		public int? OrderId { get; set; }
		public Order? Order { get; set; }

		public string EmailType { get; set; } = string.Empty;
		public string ToEmail { get; set; } = string.Empty;
		public string Subject { get; set; } = string.Empty;
		public string Body { get; set; } = string.Empty;
		public string Status { get; set; } = "Pending";
		public string? ErrorMessage { get; set; }

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
		public DateTime? SentAt { get; set; }
		public int RetryCount { get; set; } = 0;
	}

}
