using System.Net.Http;
using System.Net.Http.Json;
using CreditsService.DTO;

public class AccountClient(HttpClient httpClient) : IAccountClient
{
    public async Task DepositAsync(Guid accountId, decimal amount)
    {
        var request = new
        {
            accountId,
            amount
        };

        var response = await httpClient.PostAsJsonAsync("/api/accounts/deposit", request);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Ошибка начисления денег на счет");
        }
    }

    public async Task WithdrawAsync(Guid accountId, decimal amount)
    {
        var request = new
        {
            accountId,
            amount
        };

        var response = await httpClient.PostAsJsonAsync("/api/accounts/withdraw", request);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Ошибка списания денег со счета");
        }
    }

    public async Task WithdrawInternalAsync(Guid accountId, decimal amount)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/accounts/internal/withdraw")
        {
            Content = JsonContent.Create(new
            {
                accountId,
                amount
            })
        };

        request.Headers.Add("X-Internal-Api-Key", "KRUTOBANK_INTERNAL_KEY_2026");

        var response = await httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Ошибка внутреннего списания денег со счета");
        }
    }

    public async Task<bool> IsAccountOwnedByUser(Guid accountId, Guid userId)
    {
        var request = new HttpRequestMessage(
            HttpMethod.Get,
            $"/api/accounts/internal/user/{userId}/accounts?onlyOpened=true");

        request.Headers.Add("X-Internal-Api-Key", "KRUTOBANK_INTERNAL_KEY_2026");

        var response = await httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
            return false;

        var accounts = await response.Content.ReadFromJsonAsync<List<UserAccountDto>>();

        return accounts != null && accounts.Any(a => a.AccountId == accountId);
    }

    public async Task TransferAsync(Guid fromAccountId, Guid toAccountId, decimal amount)
    {
        var request = new
        {
            fromAccountId,
            toAccountId,
            amount
        };

        var response = await httpClient.PostAsJsonAsync("/api/accounts/transfer", request);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Ошибка перевода средств");
        }
    }

    public async Task TransferInternalAsync(Guid fromAccountId, Guid toAccountId, decimal amount)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/accounts/internal/transfer")
        {
            Content = JsonContent.Create(new
            {
                fromAccountId,
                toAccountId,
                amount
            })
        };

        request.Headers.Add("X-Internal-Api-Key", "KRUTOBANK_INTERNAL_KEY_2026");

        var response = await httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Ошибка внутреннего перевода средств");
        }
    }

    public async Task<BankAccountInfoDto> GetMasterAccountAsync()
    {
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/accounts/internal/bank/master");
        request.Headers.Add("X-Internal-Api-Key", "KRUTOBANK_INTERNAL_KEY_2026");

        var response = await httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
            throw new Exception("Ошибка получения мастер-счета банка");

        return await response.Content.ReadFromJsonAsync<BankAccountInfoDto>();
    }
}