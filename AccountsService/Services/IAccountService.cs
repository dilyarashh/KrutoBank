using AccountsService.DTO;
using AccountsService.Entities;

namespace AccountsService.Services;

public interface IAccountService
{
    Task<Account> CreateAccountAsync(CreateAccountRequest request);
    Task CloseAccountAsync(Guid accountId);
}