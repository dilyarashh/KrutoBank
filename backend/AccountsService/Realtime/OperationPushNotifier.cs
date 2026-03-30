using AccountsService.Entities.Enums;
using AccountsService.Repositories;

namespace AccountsService.Realtime;

public class OperationPushNotifier(
    IAccountRepository accountRepository,
    IPushNotificationSender pushNotificationSender) : IOperationPushNotifier
{
    public async Task NotifyOperationCreatedAsync(
        Guid accountId,
        Guid operationId,
        decimal amount,
        string operationType,
        string currency,
        CancellationToken ct = default)
    {
        var clientTokens = await accountRepository.GetPushTokensForAccountOwnersAsync(accountId, PushAudience.Client);
        var employeeTokens = await accountRepository.GetPushTokensByAudienceAsync(PushAudience.Employee);

        var payload = new Dictionary<string, string>
        {
            ["accountId"] = accountId.ToString(),
            ["operationId"] = operationId.ToString(),
            ["operationType"] = operationType,
            ["amount"] = amount.ToString(System.Globalization.CultureInfo.InvariantCulture),
            ["currency"] = currency
        };

        if (clientTokens.Count != 0)
        {
            await pushNotificationSender.SendAsync(
                clientTokens,
                "Новая операция по счету",
                $"{operationType}: {amount} {currency}",
                payload,
                ct);
        }

        if (employeeTokens.Count != 0)
        {
            await pushNotificationSender.SendAsync(
                employeeTokens,
                "Новая операция клиента",
                $"Счет {accountId}: {operationType} {amount} {currency}",
                payload,
                ct);
        }
    }
}
