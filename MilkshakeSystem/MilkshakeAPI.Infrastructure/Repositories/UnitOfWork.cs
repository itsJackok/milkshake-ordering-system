using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using MilkshakeAPI.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Infrastructure.Repositories
{
	public class UnitOfWork : IUnitOfWork
	{
		private readonly MilkshakeDbContext _context;

		private IRepository<User>? _users;
		private IRepository<Order>? _orders;
		private IRepository<OrderItem>? _orderItems;
		private IRepository<Lookup>? _lookups;
		private IRepository<Restaurant>? _restaurants;
		private IRepository<DiscountTier>? _discountTiers;
		private IRepository<Configuration>? _configurations;
		private IRepository<AuditLog>? _auditLogs;
		private IRepository<Payment>? _payments;
		private IRepository<EmailLog>? _emailLogs;

		public UnitOfWork(MilkshakeDbContext context)
		{
			_context = context;
		}

		public IRepository<User> Users =>
			_users ??= new Repository<User>(_context);

		public IRepository<Order> Orders =>
			_orders ??= new Repository<Order>(_context);

		public IRepository<OrderItem> OrderItems =>
			_orderItems ??= new Repository<OrderItem>(_context);

		public IRepository<Lookup> Lookups =>
			_lookups ??= new Repository<Lookup>(_context);

		public IRepository<Restaurant> Restaurants =>
			_restaurants ??= new Repository<Restaurant>(_context);

		public IRepository<DiscountTier> DiscountTiers =>
			_discountTiers ??= new Repository<DiscountTier>(_context);

		public IRepository<Configuration> Configurations =>
			_configurations ??= new Repository<Configuration>(_context);

		public IRepository<AuditLog> AuditLogs =>
			_auditLogs ??= new Repository<AuditLog>(_context);

		public IRepository<Payment> Payments =>
			_payments ??= new Repository<Payment>(_context);

		public IRepository<EmailLog> EmailLogs =>
			_emailLogs ??= new Repository<EmailLog>(_context);

		public async Task<int> SaveChangesAsync()
		{
			return await _context.SaveChangesAsync();
		}

		public void Dispose()
		{
			_context.Dispose();
		}
	}

}
