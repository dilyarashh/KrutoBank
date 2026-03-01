using AccountsService.DTO;
using AccountsService.Entities;
using AccountsService.Services;
using Microsoft.AspNetCore.Http.HttpResults;

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
    [ProducesResponseType(typeof(Guid), 200)]
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
    [ProducesResponseType(typeof(NoContent), 204)]
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
    [ProducesResponseType(typeof(NoContent), 204)]
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
    [ProducesResponseType(typeof(NoContent), 204)]
    public async Task<IActionResult> Withdraw(MoneyOperationRequest request)
    {
        await service.WithdrawAsync(request.AccountId, request.Amount);
        return NoContent();
    }

    /// <summary>
    /// Получить информацию по своему счету
    /// </summary>
    [Authorize]
    [HttpGet("{accountId}/my-account")]
    [ProducesResponseType(typeof(AccountDetailsDto), 200)]
    public async Task<IActionResult> GetMyAccount(Guid accountId)
    {
        var dto = await service.GetMyAccountAsync(accountId);
        return Ok(dto);
    }

    /// <summary>
    /// Получить информацию по любому счету (доступно только сотруднику)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet("{accountId}")]
    [ProducesResponseType(typeof(AccountDetailsDto), 200)]
    public async Task<IActionResult> GetAccount(Guid accountId)
    {
        var dto = await service.GetAccountAsync(accountId);
        return Ok(dto);
    }

    /// <summary>
    /// Получить историю операций по своему счету
    /// </summary>
    [Authorize]
    [HttpGet("{accountId}/my-operations")]
    [ProducesResponseType(typeof(AccountOperation), 200)]
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
    [ProducesResponseType(typeof(UserAccountDto), 200)]
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
    [ProducesResponseType(typeof(AccountOperation), 200)]
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
    
    /// <summary>
    /// Получить список своих счетов
    /// </summary>
    [Authorize]
    [HttpGet("my-accounts")]
    [ProducesResponseType(typeof(IEnumerable<UserAccountDto>), 200)]
    public async Task<IActionResult> GetMyAccounts([FromQuery] bool? onlyOpened)
    {
        var result = await service.GetMyAccountsAsync(onlyOpened);
        return Ok(result);
    }
    
    /// <summary>
    /// Получить счета конкретного пользователя (только сотрудник)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet("user/{userId}")]
    [ProducesResponseType(typeof(IEnumerable<UserAccountDto>), 200)]
    public async Task<IActionResult> GetUserAccountsByUserId(
        Guid userId,
        [FromQuery] bool? onlyOpened)
    {
        var result = await service.GetUserAccountsByUserIdAsync(userId, onlyOpened);
        return Ok(result);
    }
}
