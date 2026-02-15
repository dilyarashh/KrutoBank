using AccountsService.DTO;
using AccountsService.Services;

namespace AccountsService.Controllers;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/accounts")]
[Authorize]
public class AccountsController(AccountService service) : ControllerBase
{
    /// <summary>
    /// Открыть счет
    /// </summary>
    [Authorize]
    [HttpPost]
    public async Task<IActionResult> CreateAccount(CreateAccountRequest request)
    {
        var id = await service.CreateAccountAsync(request);
        return Ok(id);
    }
    
    /// <summary>
    /// Закрыть счет
    /// </summary>
    [Authorize]
    [HttpPatch]
    public async Task<IActionResult> CloseAccount(Guid id)
    {
        await service.CloseAccountAsync(id);
        return NoContent();
    }
}
