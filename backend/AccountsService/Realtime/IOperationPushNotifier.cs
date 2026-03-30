namespace AccountsService.Realtime;

public interface IOperationPushNotifier
{
    Task NotifyOperationCreatedAsync(Guid accountId, Guid operationId, decimal amount, string operationType, string currency, CancellationToken ct = default);
}
