namespace AccountsService.Realtime;

public interface IOperationRealtimeNotifier
{
    Task NotifyOperationChangedAsync(Guid accountId, CancellationToken ct = default);
}
