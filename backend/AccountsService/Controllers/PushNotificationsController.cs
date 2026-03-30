using AccountsService.DTO;
using AccountsService.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AccountsService.Controllers;

[ApiController]
[Route("api/push-subscriptions")]
[Authorize]
public class PushNotificationsController(IPushSubscriptionService pushSubscriptionService) : ControllerBase
{
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Register([FromBody] RegisterPushSubscriptionRequest request)
    {
        await pushSubscriptionService.RegisterAsync(request);
        return NoContent();
    }

    [HttpDelete]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Remove([FromBody] RemovePushSubscriptionRequest request)
    {
        await pushSubscriptionService.RemoveAsync(request.Token);
        return NoContent();
    }
}
