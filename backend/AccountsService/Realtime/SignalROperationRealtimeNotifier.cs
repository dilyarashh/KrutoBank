using AccountsService.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace AccountsService.Realtime;

public class SignalROperationRealtimeNotifier(IHubContext<AccountOperationsHub> hubContext)
    : IOperationRealtimeNotifier
{
    public Task NotifyOperationChangedAsync(Guid accountId, CancellationToken ct = default)
    {
        return hubContext.Clients
            .Group(AccountOperationsHub.GetGroupName(accountId))
            .SendAsync("OperationsInvalidated", accountId, DateTime.UtcNow, ct);
    }
}
