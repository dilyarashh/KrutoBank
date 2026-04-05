using AccountsService.Data;
using AccountsService.Errors.Exceptions;
using AccountsService.Helper;
using AccountsService.Hubs;
using AccountsService.Idempotency;
using AccountsService.Kafka;
using AccountsService.Realtime;
using AccountsService.Repositories;
using AccountsService.Resilience;
using AccountsService.Services;
using AccountsService.Services.Validators;
using FluentValidation;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Polly;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient("Monitoring", client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Monitoring:BaseUrl"]!);
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
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<AccountsDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<AccountService>();
builder.Services.AddHttpContextAccessor();

builder.Services.AddScoped<IAccountService, AccountService>();
builder.Services.AddScoped<ICurrentUser, CurrentUser>();
builder.Services.AddScoped<IAccountRepository, AccountRepository>();
builder.Services.AddScoped<IPushSubscriptionService, PushSubscriptionService>();
builder.Services.AddSingleton<IOperationRealtimeNotifier, SignalROperationRealtimeNotifier>();
builder.Services.AddSingleton<IPushNotificationSender, FirebasePushNotificationSender>();
builder.Services.AddScoped<IOperationPushNotifier, OperationPushNotifier>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateAccountValidator>();
builder.Services.AddSignalR();

builder.Services.AddHttpClient<CurrencyService>();
builder.Services.AddSingleton<KafkaProducer>();
builder.Services.AddSingleton<KafkaInitializer>();
builder.Services.AddHostedService<KafkaConsumerService>();
builder.Services.AddSingleton<ServiceCallCircuitState>();

builder.Services.AddHttpClient<IUsersClient, UsersClient>(client =>
{
    client.BaseAddress = new Uri("http://localhost:5260");
})
    .AddHttpMessageHandler(sp => new ServiceCallResilienceHandler(
        "UsersService",
        sp.GetRequiredService<ServiceCallCircuitState>(),
        sp.GetRequiredService<ILogger<ServiceCallResilienceHandler>>()));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Authentication:Authority"];
        options.RequireHttpsMetadata = false;
        options.MapInboundClaims = false;
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;

                if (!string.IsNullOrEmpty(accessToken) &&
                    path.StartsWithSegments(AccountOperationsHub.HubRoute))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            }
        };

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

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AccountsDbContext>();

    var retry = Policy
        .Handle<Exception>()
        .WaitAndRetry(5, retryAttempt => 
            TimeSpan.FromSeconds(5));

    retry.Execute(() => db.Database.Migrate());
    db.Database.ExecuteSqlRaw("""
        CREATE TABLE IF NOT EXISTS "IdempotencyRequests" (
            "Id" uuid NOT NULL,
            "Key" text NOT NULL,
            "UserScope" text NOT NULL,
            "Method" text NOT NULL,
            "RequestPath" text NOT NULL,
            "QueryString" text NOT NULL,
            "RequestHash" text NOT NULL,
            "State" text NOT NULL,
            "ResponseStatusCode" integer NULL,
            "ResponseContentType" text NULL,
            "ResponseBody" text NOT NULL DEFAULT '',
            "CreatedAt" timestamp with time zone NOT NULL,
            "CompletedAt" timestamp with time zone NULL,
            CONSTRAINT "PK_IdempotencyRequests" PRIMARY KEY ("Id")
        );
        CREATE UNIQUE INDEX IF NOT EXISTS "IX_IdempotencyRequests_UserScope_Key"
        ON "IdempotencyRequests" ("UserScope", "Key");
        """);
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<TraceMiddleware>();
app.UseMiddleware<RequestTimingMiddleware>();
app.UseMiddleware<UnstableServiceMiddleware>();
app.UseMiddleware<ExceptionMiddleware>();

app.UseCors("FrontCors");

app.UseAuthentication();
app.UseMiddleware<IdempotencyMiddleware>();
app.UseAuthorization();
app.UseMiddleware<UnstableServiceMiddleware>();

app.MapControllers();
app.MapHub<AccountOperationsHub>(AccountOperationsHub.HubRoute);

app.Run();
