using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Polly;
using System.Diagnostics;
using System.Reflection;
using System.Security.Claims;
using UsersService.Helper;
using UsersService.Infrastructure.Auth;
using UsersService.Infrastructure.Errors.Exceptions;
using UsersService.Infrastructure.Repositories;
using UsersService.Services;
using UsersService.Services.Validators;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient("Monitoring", client =>
{
    client.BaseAddress = new Uri("http://localhost:5300");
});

builder.Services.AddControllers();

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontCors", policy =>
    {
        var origins = builder.Configuration
            .GetSection("Cors:AllowedOrigins")
            .Get<string[]>() ?? Array.Empty<string>();

        policy
            .WithOrigins(origins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<UsersDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUser, CurrentUser>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<PagedRequestValidator>();

builder.Services.AddSwaggerGen(options =>
{
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    options.IncludeXmlComments(xmlPath);
    
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Введите JWT токен в формате: Bearer {токен}"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference 
                { 
                    Type = ReferenceType.SecurityScheme, 
                    Id = "Bearer" 
                }
            },
            []
        }
    });
});

builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        options.Authority = builder.Configuration["Authentication:Authority"];
        options.RequireHttpsMetadata = false;
        options.MapInboundClaims = false;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidAudience = builder.Configuration["Authentication:Audience"],
            NameClaimType = ClaimTypes.NameIdentifier,
            RoleClaimType = ClaimTypes.Role
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<UsersDbContext>();

    var retry = Policy
        .Handle<Exception>()
        .WaitAndRetry(5, retryAttempt => 
            TimeSpan.FromSeconds(5));

    retry.Execute(() => db.Database.Migrate());
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<TraceMiddleware>();
app.UseMiddleware<RequestTimingMiddleware>();
app.UseMiddleware<UnstableServiceMiddleware>();
app.UseMiddleware<ExceptionMiddleware>();
app.UseCors("FrontCors");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
