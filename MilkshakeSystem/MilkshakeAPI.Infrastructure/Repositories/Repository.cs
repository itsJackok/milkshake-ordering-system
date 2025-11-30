using Microsoft.EntityFrameworkCore;
using MilkshakeAPI.Domain.Interfaces;
using MilkshakeAPI.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Infrastructure.Repositories
{
	public class Repository<T> : IRepository<T> where T : class
	{
		protected readonly MilkshakeDbContext _context;
		protected readonly DbSet<T> _dbSet;

		public Repository(MilkshakeDbContext context)
		{
			_context = context;
			_dbSet = context.Set<T>();
		}

		public async Task<T?> GetByIdAsync(int id)
		{
			return await _dbSet.FindAsync(id);
		}

		public async Task<IEnumerable<T>> GetAllAsync()
		{
			return await _dbSet.ToListAsync();
		}

		public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
		{
			return await _dbSet.Where(predicate).ToListAsync();
		}

		public async Task<T> AddAsync(T entity)
		{
			await _dbSet.AddAsync(entity);
			return entity;
		}

		public async Task UpdateAsync(T entity)
		{
			_dbSet.Update(entity);
			await Task.CompletedTask;
		}

		public async Task DeleteAsync(T entity)
		{
			_dbSet.Remove(entity);
			await Task.CompletedTask;
		}

		public async Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate)
		{
			return await _dbSet.AnyAsync(predicate);
		}
	}
}
