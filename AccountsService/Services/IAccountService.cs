using AccountsService.DTO;
using AccountsService.Entities;

namespace AccountsService.Services;

public interface IAccountService
{
    Task<Account> CreateAccountAsync(CreateAccountRequest request);
    Task CloseAccountAsync(Guid accountId);
    Task<bool> DepositAsync(Guid accountId, decimal amount);
    Task<bool> WithdrawAsync(Guid accountId, decimal amount);
    Task<IEnumerable<AccountOperation>> GetMyAccountHistoryAsync(Guid accountId);
    Task<IEnumerable<UserAccount>> GetAllUserAccountsAsync();
    Task<IEnumerable<AccountOperation>> GetAccountHistoryAsync(Guid accountId);

}