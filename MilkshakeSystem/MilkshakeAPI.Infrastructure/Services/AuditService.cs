using MilkshakeAPI.Domain.Entities;
using MilkshakeAPI.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkshakeAPI.Infrastructure.Services
{
	public class AuditService : IAuditService
	{
		private readonly IUnitOfWork _unitOfWork;

		public AuditService(IUnitOfWork unitOfWork)
		{
			_unitOfWork = unitOfWork;
		}

		public async Task LogChangeAsync(
			int userId,
			string entityType,
			int entityId,
			string action,
			string? fieldChanged = null,
			string? oldValue = null,
			string? newValue = null)
		{
			var auditLog = new AuditLog
			{
				UserId = userId,
				EntityType = entityType,
				EntityId = entityId,
				Action = action,
				FieldChanged = fieldChanged,
				OldValue = oldValue,
				NewValue = newValue,
				Timestamp = DateTime.UtcNow,
				IPAddress = null
			};

			await _unitOfWork.AuditLogs.AddAsync(auditLog);
			await _unitOfWork.SaveChangesAsync();
		}
	}

}
