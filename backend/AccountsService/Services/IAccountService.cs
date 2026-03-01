using AccountsService.DTO;
using AccountsService.Entities;

namespace AccountsService.Services;

public interface IAccountService
{
    Task<Account> CreateAccountAsync(CreateAccountRequest request);
    Task CloseAccountAsync(Guid accountId);
    Task<bool> DepositAsync(Guid accountId, decimal amount);
    Task<bool> WithdrawAsync(Guid accountId, decimal amount);
    Task<AccountDetailsDto> GetMyAccountAsync(Guid accountId);
    Task<AccountDetailsDto> GetAccountAsync(Guid accountId);
    Task<IEnumerable<AccountOperation>> GetMyAccountHistoryAsync(Guid accountId);
    Task<PagedResult<UserAccountDto>> GetAllUserAccountsAsync(bool? onlyOpened, int page, int pageSize);
    Task<IEnumerable<AccountOperation>> GetAccountHistoryAsync(Guid accountId);
    Task<IEnumerable<UserAccountDto>> GetMyAccountsAsync(bool? onlyOpened);
    Task<IEnumerable<UserAccountDto>> GetUserAccountsByUserIdAsync(Guid userId, bool? onlyOpened);
}