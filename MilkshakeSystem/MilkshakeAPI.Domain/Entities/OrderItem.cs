using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Domain.Entities
{

	public class OrderItem
	{
		public int Id { get; set; }
		public int OrderId { get; set; }
		public Order? Order { get; set; }

		public int FlavourId { get; set; }
		public Lookup? Flavour { get; set; }

		public int ToppingId { get; set; }
		public Lookup? Topping { get; set; }

		public int ConsistencyId { get; set; }
		public Lookup? Consistency { get; set; }

		public decimal FlavourPrice { get; set; }
		public decimal ToppingPrice { get; set; }
		public decimal ConsistencyPrice { get; set; }
		public decimal ItemTotal { get; set; }

		public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
	}

}
