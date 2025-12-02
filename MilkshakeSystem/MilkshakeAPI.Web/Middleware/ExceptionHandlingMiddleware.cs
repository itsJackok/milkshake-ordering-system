using System.Net;
using System.Text.Json;

namespace MilkshakeAPI.Web.Middleware
{
	public class ExceptionHandlingMiddleware
	{
		private readonly RequestDelegate _next;
		private readonly ILogger<ExceptionHandlingMiddleware> _logger;

		public ExceptionHandlingMiddleware(
			RequestDelegate next,
			ILogger<ExceptionHandlingMiddleware> logger)
		{
			_next = next;
			_logger = logger;
		}

		public async Task InvokeAsync(HttpContext context)
		{
			try
			{
				await _next(context);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "An unhandled exception occurred");
				await HandleExceptionAsync(context, ex);
			}
		}

		private static Task HandleExceptionAsync(HttpContext context, Exception exception)
		{
			var code = HttpStatusCode.InternalServerError;
			var result = string.Empty;

			switch (exception)
			{
				case ArgumentNullException:
				case ArgumentException:
					code = HttpStatusCode.BadRequest;
					result = JsonSerializer.Serialize(new
					{
						success = false,
						message = exception.Message,
						errors = new[] { "Invalid request parameters" }
					});
					break;

				case UnauthorizedAccessException:
					code = HttpStatusCode.Unauthorized;
					result = JsonSerializer.Serialize(new
					{
						success = false,
						message = "Unauthorized access",
						errors = new[] { exception.Message }
					});
					break;

				case KeyNotFoundException:
					code = HttpStatusCode.NotFound;
					result = JsonSerializer.Serialize(new
					{
						success = false,
						message = "Resource not found",
						errors = new[] { exception.Message }
					});
					break;

				default:
					code = HttpStatusCode.InternalServerError;
					result = JsonSerializer.Serialize(new
					{
						success = false,
						message = "An error occurred while processing your request",
						errors = new[] { "Internal server error" }
					});
					break;
			}

			context.Response.ContentType = "application/json";
			context.Response.StatusCode = (int)code;

			return context.Response.WriteAsync(result);
		}
	}

	public static class ExceptionHandlingMiddlewareExtensions
	{
		public static IApplicationBuilder UseExceptionHandlingMiddleware(
			this IApplicationBuilder builder)
		{
			return builder.UseMiddleware<ExceptionHandlingMiddleware>();
		}
	}
}