using AccountsService.DTO;
using AccountsService.Services;

namespace AccountsService.Controllers;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/accounts")]
[Authorize]
public class AccountsController(IAccountService service) : ControllerBase
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
    
    /// <summary>
    /// Пополнить счет
    /// </summary>
    [Authorize]
    [HttpPost("deposit")]
    public async Task<IActionResult> Deposit(MoneyOperationRequest request)
    {
        await service.DepositAsync(request.AccountId, request.Amount);
        return NoContent();
    }

    /// <summary>
    /// Снять деньги со счета
    /// </summary>
    [Authorize]
    [HttpPost("withdraw")]
    public async Task<IActionResult> Withdraw(MoneyOperationRequest request)
    {
        await service.WithdrawAsync(request.AccountId, request.Amount);
        return NoContent();
    }
    
    /// <summary>
    /// Получить историю операций по своему счету
    /// </summary>
    [Authorize]
    [HttpGet("{accountId}/my-operations")]
    public async Task<IActionResult> GetMyAccountHistory(Guid accountId)
    {
        var operations = await service.GetMyAccountHistoryAsync(accountId);

        return Ok(operations.Select(o => new
        {
            o.CreatedAt,
            Type = o.Type.ToString(),
            o.Amount
        }));
    }

    /// <summary>
    /// Получить счета всех клиентов (доступно только сотруднику)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet("all-user-accounts")]
    public async Task<IActionResult> GetAllUsersAccount(
        [FromQuery] bool? onlyOpened,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var result = await service.GetAllUserAccountsAsync(onlyOpened, page, pageSize);

        return Ok(result);
    }

    /// <summary>
    /// Получить историю операций любого счета (только сотрудник)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet("{accountId}/operations")]
    public async Task<IActionResult> GetAccountHistory(Guid accountId)
    {
        var operations = await service.GetAccountHistoryAsync(accountId);

        return Ok(operations.Select(o => new
        {
            o.CreatedAt,
            Type = o.Type.ToString(),
            o.Amount
        }));
    }
}
