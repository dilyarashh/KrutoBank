using System.Security.Claims;
using AuthService.Models.Passwords;
using AuthService.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OpenIddict.Validation.AspNetCore;

namespace AuthService.Controllers;

[ApiController]
[Route("api/passwords")]
public class PasswordsController(IUsersServiceClient usersServiceClient) : ControllerBase
{
    [HttpPost("set-initial")]
    [Authorize(Roles = "Employee", AuthenticationSchemes = OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme)]
    public async Task<IActionResult> SetInitialPassword([FromBody] SetInitialPasswordRequest request)
    {
        try
        {
            var user = await usersServiceClient.GetByIdAsync(request.UserId);
            if (user is null)
            {
                return NotFound("Пользователь не найден");
            }

            var updated = await usersServiceClient.UpdatePasswordHashAsync(
                request.UserId,
                BCrypt.Net.BCrypt.HashPassword(request.NewPassword));
            if (!updated)
            {
                return BadRequest("Не удалось обновить пароль");
            }

            return NoContent();
        }
        catch (HttpRequestException)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable,
                "UsersService недоступен. Запустите сервис пользователей.");
        }
    }

    [HttpPost("change")]
    [Authorize(AuthenticationSchemes = OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme)]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userIdRaw = User.FindFirstValue(ClaimTypes.NameIdentifier)
                        ?? User.FindFirstValue("sub");

        if (string.IsNullOrWhiteSpace(userIdRaw) || !Guid.TryParse(userIdRaw, out var userId))
        {
            return Unauthorized("Не удалось определить пользователя");
        }

        try
        {
            var user = await usersServiceClient.GetByIdAsync(userId);
            if (user is null)
            {
                return NotFound("Пользователь не найден");
            }

            if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.HashPassword))
            {
                return BadRequest("Текущий пароль неверный");
            }

            var updated = await usersServiceClient.UpdatePasswordHashAsync(
                userId,
                BCrypt.Net.BCrypt.HashPassword(request.NewPassword));
            if (!updated)
            {
                return BadRequest("Не удалось обновить пароль");
            }

            return NoContent();
        }
        catch (HttpRequestException)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable,
                "UsersService недоступен. Запустите сервис пользователей.");
        }
    }
}
