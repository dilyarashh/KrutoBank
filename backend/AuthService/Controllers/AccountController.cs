using System.Net;
using System.Security.Claims;
using AuthService.Models;
using AuthService.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OpenIddict.Validation.AspNetCore;

namespace AuthService.Controllers;

[ApiController]
[Route("account")]
public class AccountController(IUsersServiceClient usersServiceClient) : Controller
{
    /// <summary>
    /// Регистрация пользователя сотрудником (можно создать Client или Employee)
    /// </summary>
    [HttpPost("register")]
    [Authorize(Roles = "Employee", AuthenticationSchemes = OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (request.Birthday > DateOnly.FromDateTime(DateTime.UtcNow))
        {
            return BadRequest("Дата рождения не может быть в будущем");
        }

        try
        {
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            var result = await usersServiceClient.CreateUserAsync(request, passwordHash);
            if (!result.Success)
            {
                return BadRequest(result.Error ?? "Не удалось создать пользователя");
            }

            return Ok(new { userId = result.UserId });
        }
        catch (HttpRequestException)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable,
                "UsersService недоступен. Запустите сервис пользователей.");
        }
    }

    [HttpGet("login")]
    public IActionResult Login([FromQuery] string? returnUrl = null)
    {
        var model = new LoginViewModel
        {
            ReturnUrl = string.IsNullOrWhiteSpace(returnUrl) ? "/swagger" : returnUrl
        };

        return Content(RenderLoginPage(model), "text/html");
    }

    [HttpPost("login")]
    public async Task<IActionResult> LoginPost([FromForm] LoginViewModel model)
    {
        var returnUrl = string.IsNullOrWhiteSpace(model.ReturnUrl) ? "/swagger" : model.ReturnUrl;

        if (!ModelState.IsValid)
        {
            model.ReturnUrl = returnUrl;
            model.Error = "Заполните все поля";
            return Content(RenderLoginPage(model), "text/html");
        }

        Models.Internal.InternalUserAuthDto? user;
        try
        {
            user = await usersServiceClient.GetByPhoneAsync(model.Phone);
        }
        catch (HttpRequestException)
        {
            model.ReturnUrl = returnUrl;
            model.Error = "Сервис пользователей временно недоступен. Повторите позже.";
            return Content(RenderLoginPage(model), "text/html");
        }

        if (user is null || !BCrypt.Net.BCrypt.Verify(model.Password, user.HashPassword))
        {
            model.ReturnUrl = returnUrl;
            model.Error = "Неверный логин или пароль";
            return Content(RenderLoginPage(model), "text/html");
        }

        if (user.IsBlocked)
        {
            model.ReturnUrl = returnUrl;
            model.Error = "Пользователь заблокирован";
            return Content(RenderLoginPage(model), "text/html");
        }

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new("sub", user.Id.ToString()),
            new(ClaimTypes.Role, user.Role),
            new("role", user.Role)
        };

        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);

        if (!Url.IsLocalUrl(returnUrl))
        {
            return BadRequest("Некорректный returnUrl");
        }

        return Redirect(returnUrl);
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromForm] string? returnUrl = null)
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        var target = string.IsNullOrWhiteSpace(returnUrl) ? "/" : returnUrl;

        if (!Url.IsLocalUrl(target))
        {
            return BadRequest("Некорректный returnUrl");
        }

        return Redirect(target);
    }

    private static string RenderLoginPage(LoginViewModel model)
    {
        var encodedPhone = WebUtility.HtmlEncode(model.Phone);
        var encodedReturnUrl = WebUtility.HtmlEncode(model.ReturnUrl);
        var errorBlock = string.IsNullOrWhiteSpace(model.Error)
            ? string.Empty
            : $"<p class=\"error\">{WebUtility.HtmlEncode(model.Error)}</p>";

        return $$"""
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>KrutoBank SSO Login</title>
    <style>
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #edf6ff 0%, #ffffff 45%, #e8fff0 100%);
            min-height: 100vh;
            display: grid;
            place-items: center;
            color: #102a43;
        }
        .card {
            width: min(92vw, 420px);
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 20px 50px rgba(16, 42, 67, 0.12);
        }
        h1 {
            margin: 0 0 6px;
            font-size: 22px;
        }
        p {
            margin: 0 0 16px;
            color: #486581;
            font-size: 14px;
        }
        label {
            display: block;
            margin-top: 12px;
            margin-bottom: 6px;
            font-size: 13px;
            color: #334e68;
        }
        input {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #bcccdc;
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 14px;
        }
        button {
            margin-top: 16px;
            width: 100%;
            border: none;
            border-radius: 10px;
            padding: 12px;
            background: #0f4c81;
            color: white;
            font-weight: 600;
            cursor: pointer;
        }
        .error {
            margin: 10px 0;
            color: #b42318;
            background: #ffebe9;
            border: 1px solid #fecdca;
            border-radius: 8px;
            padding: 8px 10px;
            font-size: 13px;
        }
        .meta {
            margin-top: 12px;
            font-size: 12px;
            color: #627d98;
        }
    </style>
</head>
<body>
    <main class="card">
        <h1>Единый вход KrutoBank</h1>
        <p>Введите логин и пароль только на этой странице. Остальные сервисы пароль не получают.</p>
        {{errorBlock}}
        <form method="post" action="/account/login">
            <input type="hidden" name="ReturnUrl" value="{{encodedReturnUrl}}" />
            <label for="phone">Телефон</label>
            <input id="phone" name="Phone" type="text" value="{{encodedPhone}}" autocomplete="username" />
            <label for="password">Пароль</label>
            <input id="password" name="Password" type="password" autocomplete="current-password" />
            <button type="submit">Войти</button>
        </form>
        <div class="meta">AuthService (OIDC Provider)</div>
    </main>
</body>
</html>
""";
    }
}
