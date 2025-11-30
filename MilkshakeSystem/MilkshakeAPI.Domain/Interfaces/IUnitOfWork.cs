using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using MilkshakeAPI.Domain.Entities;


namespace MilkshakeAPI.Domain.Interfaces
{
	public interface IUnitOfWork : IDisposable
	{
		IRepository<User> Users { get; }
		IRepository<Order> Orders { get; }
		IRepository<OrderItem> OrderItems { get; }
		IRepository<Lookup> Lookups { get; }
		IRepository<Restaurant> Restaurants { get; }
		IRepository<DiscountTier> DiscountTiers { get; }
		IRepository<Configuration> Configurations { get; }
		IRepository<AuditLog> AuditLogs { get; }
		IRepository<Payment> Payments { get; }
		IRepository<EmailLog> EmailLogs { get; }

		Task<int> SaveChangesAsync();
	}

}
