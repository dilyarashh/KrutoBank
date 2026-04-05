using AuthService.Helper;
using AuthService.Resilience;
using AuthService.Data;
using AuthService.Middleware;
using AuthService.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using OpenIddict.Validation.AspNetCore;
using static OpenIddict.Abstractions.OpenIddictConstants;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient("Monitoring", client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Monitoring:BaseUrl"]!);
});

builder.Services.AddControllersWithViews();

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

builder.Services.AddDbContext<OpenIddictDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.UseOpenIddict();
});

builder.Services.AddHttpClient<IUsersServiceClient, UsersServiceClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["UsersService:BaseUrl"] ?? "http://localhost:5260");
})
    .AddHttpMessageHandler(sp => new ServiceCallResilienceHandler(
        "UsersService",
        sp.GetRequiredService<ServiceCallCircuitState>(),
        sp.GetRequiredService<ILogger<ServiceCallResilienceHandler>>()));
builder.Services.AddSingleton<ServiceCallCircuitState>();

builder.Services
    .AddAuthentication(options =>
    {
        options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    })
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
    {
        options.LoginPath = "/account/login";
        options.LogoutPath = "/account/logout";
        options.Cookie.Name = "krutobank.auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
    })
    .AddPolicyScheme(JwtBearerDefaults.AuthenticationScheme, JwtBearerDefaults.AuthenticationScheme, options =>
    {
        options.ForwardDefaultSelector = context =>
        {
            var header = context.Request.Headers["Authorization"].ToString();
            var hasBearer = header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase);

            return hasBearer
                ? OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme
                : CookieAuthenticationDefaults.AuthenticationScheme;
        };
    });

builder.Services.AddOpenIddict()
    .AddCore(options =>
    {
        options.UseEntityFrameworkCore()
            .UseDbContext<OpenIddictDbContext>();
    })
    .AddServer(options =>
    {
        options.SetIssuer(new Uri("http://localhost:5270"));

        options.SetAuthorizationEndpointUris("/connect/authorize")
            .SetTokenEndpointUris("/connect/token")
            .SetEndSessionEndpointUris("/connect/logout");

        options.AllowAuthorizationCodeFlow()
            .AllowRefreshTokenFlow();

        options.RequireProofKeyForCodeExchange();
        options.DisableAccessTokenEncryption();

        options.RegisterScopes(Scopes.OpenId, Scopes.Profile, "roles", "users_api", "accounts_api", "credits_api", "settings_api");

        options.SetAccessTokenLifetime(TimeSpan.FromMinutes(60));
        options.SetRefreshTokenLifetime(TimeSpan.FromDays(7));

        options.AddEphemeralEncryptionKey()
            .AddEphemeralSigningKey();

        options.UseAspNetCore()
            .DisableTransportSecurityRequirement()
            .EnableAuthorizationEndpointPassthrough()
            .EnableTokenEndpointPassthrough()
            .EnableEndSessionEndpointPassthrough();
    })
    .AddValidation(options =>
    {
        options.SetIssuer(new Uri("http://localhost:5270"));
        options.UseLocalServer();
        options.UseAspNetCore();
    });

builder.Services.AddAuthorization();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<OpenIddictDbContext>();
    await db.Database.EnsureCreatedAsync();

    await SeedOpenIddictAsync(scope.ServiceProvider);
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<TraceMiddleware>();
app.UseMiddleware<RequestTimingMiddleware>();

app.UseCors("FrontCors");

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/", () => Results.Redirect("/account/login"));
app.MapControllers();

app.Run();

static async Task SeedOpenIddictAsync(IServiceProvider services)
{
    var applicationManager = services.GetRequiredService<IOpenIddictApplicationManager>();
    var scopeManager = services.GetRequiredService<IOpenIddictScopeManager>();

    await CreateScopeIfMissing(scopeManager, "users_api", "Users API");
    await CreateScopeIfMissing(scopeManager, "accounts_api", "Accounts API");
    await CreateScopeIfMissing(scopeManager, "credits_api", "Credits API");
    await CreateScopeIfMissing(scopeManager, "roles", "User roles");
    await CreateScopeIfMissing(scopeManager, "settings_api", "Settings API");

    await CreateClientIfMissing(applicationManager,
        clientId: "bank-client-web",
        displayName: "KrutoBank Client Web",
        redirectUris: ["http://localhost:3000/auth/callback", "http://localhost:5173/auth/callback"],
        postLogoutRedirectUris: ["http://localhost:3000", "http://localhost:5173"],
        permissions: ["users_api", "accounts_api", "credits_api", "roles", "settings_api"]);

    await CreateClientIfMissing(applicationManager,
        clientId: "bank-employee-web",
        displayName: "KrutoBank Employee Web",
        redirectUris: ["http://localhost:4200/auth/callback"],
        postLogoutRedirectUris: ["http://localhost:4200"],
        permissions: ["users_api", "accounts_api", "credits_api", "roles", "settings_api"]);

    await CreateClientIfMissing(applicationManager,
        clientId: "bank-client-ios",
        displayName: "KrutoBank Client Web",
        redirectUris: [
            "http://localhost:3000/auth/callback",
            "http://localhost:5173/auth/callback",
            "krutobank://callback"
        ],
        postLogoutRedirectUris: [
            "http://localhost:3000",
            "http://localhost:5173",
            "krutobank://callback"
        ],
        permissions: ["users_api", "accounts_api", "credits_api", "roles", "settings_api"]);
}

static async Task CreateScopeIfMissing(IOpenIddictScopeManager scopeManager, string name, string displayName)
{
    if (await scopeManager.FindByNameAsync(name) is not null)
    {
        return;
    }

    var descriptor = new OpenIddictScopeDescriptor
    {
        Name = name,
        DisplayName = displayName,
        Resources =
        {
            name
        }
    };

    await scopeManager.CreateAsync(descriptor);
}

static async Task CreateClientIfMissing(
    IOpenIddictApplicationManager applicationManager,
    string clientId,
    string displayName,
    IEnumerable<string> redirectUris,
    IEnumerable<string> postLogoutRedirectUris,
    IEnumerable<string> permissions)
{
    if (await applicationManager.FindByClientIdAsync(clientId) is not null)
    {
        return;
    }

    var descriptor = new OpenIddictApplicationDescriptor
    {
        ClientId = clientId,
        ConsentType = ConsentTypes.Implicit,
        DisplayName = displayName,
        ClientType = ClientTypes.Public
    };

    descriptor.Permissions.UnionWith(
    [
        Permissions.Endpoints.Authorization,
        Permissions.Endpoints.Token,
        Permissions.Endpoints.EndSession,
        Permissions.GrantTypes.AuthorizationCode,
        Permissions.GrantTypes.RefreshToken,
        Permissions.ResponseTypes.Code,
        Permissions.Prefixes.Scope + Scopes.OpenId,
        Permissions.Prefixes.Scope + Scopes.Profile,
        Permissions.Prefixes.Scope + Scopes.Email,
        Permissions.Prefixes.Scope + "roles"
    ]);

    foreach (var permission in permissions)
    {
        descriptor.Permissions.Add(Permissions.Prefixes.Scope + permission);
    }

    foreach (var uri in redirectUris)
    {
        descriptor.RedirectUris.Add(new Uri(uri));
    }

    foreach (var uri in postLogoutRedirectUris)
    {
        descriptor.PostLogoutRedirectUris.Add(new Uri(uri));
    }

    descriptor.Requirements.Add(Requirements.Features.ProofKeyForCodeExchange);

    await applicationManager.CreateAsync(descriptor);
}
