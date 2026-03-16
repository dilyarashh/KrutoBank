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

    public async Task<bool> IsMyAccount(Guid accountId)
    {
        var response = await httpClient.GetAsync($"/api/accounts/{accountId}/my-account");

        return response.IsSuccessStatusCode;
    }

    public async Task<bool> IsAccountOwnedByUser(Guid accountId, Guid userId)
    {
        var response = await httpClient.GetAsync($"/api/accounts/user/{userId}");

        if (!response.IsSuccessStatusCode)
            return false;

        var accounts = await response.Content.ReadFromJsonAsync<List<UserAccountDto>>();

        return accounts!.Any(a => a.AccountId == accountId);
    }
}