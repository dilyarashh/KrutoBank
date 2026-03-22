using System.Security.Claims;
using AccountsService.DTO;
using AccountsService.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace AccountsService.Hubs;

[Authorize]
public class AccountOperationsHub(IAccountService accountService) : Hub
{
    public const string HubRoute = "/ws/account-operations";

    public async Task SubscribeAccount(Guid accountId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, GetGroupName(accountId));
        await SendOperationsSnapshot(accountId);
    }

    public Task UnsubscribeAccount(Guid accountId)
        => Groups.RemoveFromGroupAsync(Context.ConnectionId, GetGroupName(accountId));

    public Task RequestOperations(Guid accountId)
        => SendOperationsSnapshot(accountId);

    private async Task SendOperationsSnapshot(Guid accountId)
    {
        try
        {
            var role = Context.User?.FindFirst(ClaimTypes.Role)?.Value
                       ?? Context.User?.FindFirst("role")?.Value;

            var operations = string.Equals(role, "Employee", StringComparison.OrdinalIgnoreCase)
                ? await accountService.GetAccountHistoryAsync(accountId)
                : await accountService.GetMyAccountHistoryAsync(accountId);

            var payload = operations.Select(o => new OperationDto
            {
                CreatedAt = o.CreatedAt,
                Type = o.Type.ToString(),
                Amount = o.Amount
            }).ToArray();

            await Clients.Caller.SendAsync("OperationsSnapshot", accountId, payload);
        }
        catch (Exception ex)
        {
            throw new HubException(ex.Message);
        }
    }

    public static string GetGroupName(Guid accountId) => $"account:{accountId}";
}
