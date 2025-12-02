using Microsoft.EntityFrameworkCore;
using MilkshakeAPI.Application.Interfaces;
using MilkshakeAPI.Application.Services;
using MilkshakeAPI.Domain.Interfaces;
using MilkshakeAPI.Infrastructure.Data;
using MilkshakeAPI.Infrastructure.Repositories;
using MilkshakeAPI.Infrastructure.Services;
using MilkshakeAPI.Web.Middleware;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddCors(options =>
{
	options.AddPolicy("AllowFlutter", policy =>
	{
		policy.AllowAnyOrigin()
			  .AllowAnyMethod()
			  .AllowAnyHeader();
	});
});


builder.Services.AddDbContext<MilkshakeDbContext>(options =>
	options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IAuditService, AuditService>();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IPricingService, PricingService>();
builder.Services.AddScoped<IDiscountService, DiscountService>();
builder.Services.AddScoped<ILookupService, LookupService>();
builder.Services.AddScoped<IRestaurantService, RestaurantService>();
builder.Services.AddScoped<IConfigurationService, ConfigurationService>();
builder.Services.AddScoped<IReportService, ReportService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
	c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
	{
		Title = "Milkshake API",
		Version = "v1",
		Description = "Complete API for Milky Shaky Drinks ordering system with Clean Architecture",
		Contact = new Microsoft.OpenApi.Models.OpenApiContact
		{
			Name = "Milky Shaky Drinks",
			Email = "support@milkyshaky.com"
		}
	});
});

var app = builder.Build();

app.UseExceptionHandlingMiddleware(); 

if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI(c =>
	{
		c.SwaggerEndpoint("/swagger/v1/swagger.json", "Milkshake API v1");
		c.RoutePrefix = string.Empty; 
	});
}


app.UseCors("AllowFlutter");


app.UseAuthorization();

app.MapControllers();

app.Run();