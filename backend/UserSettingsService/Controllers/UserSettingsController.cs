using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UserSettingsService.DTO;
using UserSettingsService.Entities.Enums;
using UserSettingsService.Services;

namespace UserSettingsService.Controllers;

[ApiController]
[Route("api/settings")]
[Authorize]
public class UserSettingsController(UserSettingsManager service, ICurrentUser currentUser) : ControllerBase
{
    /// Получить настройки
    [HttpGet("me")]
    public async Task<ActionResult<UserSettingsDto>> GetCustomization()
    {
        var userId = currentUser.GetUserId();
        var result = await service.GetOrCreateAsync(userId);
        return Ok(result);
    }

    /// Обновить тему
    [HttpPatch("theme")]
    public async Task<IActionResult> UpdateTheme([FromBody] Theme theme)
    {
        var userId = currentUser.GetUserId();
        await service.UpdateTheme(userId, theme);
        return NoContent();
    }

    /// Обновить скрытые счета
    [HttpPatch("hidden-accounts")]
    public async Task<IActionResult> UpdateHidden([FromBody] List<Guid> accountIds)
    {
        var userId = currentUser.GetUserId();
        await service.UpdateHiddenAccounts(userId, accountIds);
        return NoContent();
    }
}