using System.Security.Claims;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using OpenIddict.Abstractions;
using OpenIddict.Server.AspNetCore;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace AuthService.Controllers;

[ApiController]
public class AuthorizationController : Controller
{
    [HttpGet("~/connect/authorize")]
    [HttpPost("~/connect/authorize")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> Authorize()
    {
        var request = OpenIddictServerAspNetCoreHelpers.GetOpenIddictServerRequest(HttpContext)
                      ?? throw new InvalidOperationException("OpenID Connect request cannot be retrieved.");

        var authenticateResult = await HttpContext.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        if (!authenticateResult.Succeeded || authenticateResult.Principal is null)
        {
            return Challenge(
                authenticationSchemes: CookieAuthenticationDefaults.AuthenticationScheme,
                properties: new AuthenticationProperties
                {
                    RedirectUri = Request.PathBase + Request.Path + QueryString.Create(
                        Request.HasFormContentType
                            ? Request.Form.Where(parameter => parameter.Key != Parameters.Password).Select(parameter => new KeyValuePair<string, string?>(parameter.Key, parameter.Value))
                            : Request.Query.Select(parameter => new KeyValuePair<string, string?>(parameter.Key, parameter.Value)))
                });
        }

        var userId = authenticateResult.Principal.FindFirst(ClaimTypes.NameIdentifier)?.Value
                     ?? authenticateResult.Principal.FindFirst("sub")?.Value
                     ?? throw new InvalidOperationException("User id is missing in the authentication cookie.");

        var role = authenticateResult.Principal.FindFirst(ClaimTypes.Role)?.Value
                   ?? authenticateResult.Principal.FindFirst("role")?.Value
                   ?? "Client";

        var claims = new List<Claim>
        {
            new(Claims.Subject, userId),
            new(ClaimTypes.NameIdentifier, userId),
            new(Claims.Role, role),
            new(ClaimTypes.Role, role)
        };

        var identity = new ClaimsIdentity(claims, TokenValidationParameters.DefaultAuthenticationType, Claims.Name, Claims.Role);
        var principal = new ClaimsPrincipal(identity);

        principal.SetScopes(request.GetScopes());
        principal.SetResources(GetResources(principal.GetScopes()));

        principal.SetDestinations(static claim => claim.Type switch
        {
            ClaimTypes.NameIdentifier or Claims.Subject or Claims.Role or ClaimTypes.Role
                => [Destinations.AccessToken, Destinations.IdentityToken],
            _ => [Destinations.AccessToken]
        });

        return SignIn(principal, OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
    }

    [HttpPost("~/connect/token")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> Exchange()
    {
        var request = OpenIddictServerAspNetCoreHelpers.GetOpenIddictServerRequest(HttpContext)
                      ?? throw new InvalidOperationException("OpenID Connect request cannot be retrieved.");

        if (!request.IsAuthorizationCodeGrantType() && !request.IsRefreshTokenGrantType())
        {
            return BadRequest("Поддерживаются только authorization_code и refresh_token");
        }

        var authenticateResult = await HttpContext.AuthenticateAsync(OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
        if (!authenticateResult.Succeeded || authenticateResult.Principal is null)
        {
            return Forbid(OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
        }

        var principal = authenticateResult.Principal;
        principal.SetResources(GetResources(principal.GetScopes()));

        return SignIn(principal, OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
    }

    [HttpGet("~/connect/logout")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return Redirect("/account/login");
    }

    private static IEnumerable<string> GetResources(IEnumerable<string> scopes)
    {
        var resources = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var scope in scopes)
        {
            if (scope is "users_api" or "accounts_api" or "credits_api" or "settings_api")
            {
                resources.Add(scope);
            }
        }

        return resources;
    }
}
