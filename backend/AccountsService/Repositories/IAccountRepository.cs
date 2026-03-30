using AccountsService.DTO;
using AccountsService.Entities;
using AccountsService.Entities.Enums;

namespace AccountsService.Repositories;

public interface IAccountRepository
{
    Task<Account> AddAsync(Account account);
    Task<Account?> GetByIdAsync(Guid accountId);
    Task<Account?> GetByIdForUserAsync(Guid accountId, Guid userId);
    Task<IEnumerable<Account>> GetUserAccountsAsync(Guid userId);
    Task UpdateAsync(Account account);
    Task AddOperationAsync(AccountOperation operation);
    Task AddUserAccountAsync(Guid userId, Guid accountId);
    Task SaveChangesAsync();
    Task<IEnumerable<AccountOperation>> GetAccountOperationsForUserAsync(Guid accountId, Guid userId);
    Task<PagedResult<UserAccountDto>> GetAllUserAccountsAsync(
        bool? onlyOpened,
        int page,
        int pageSize);
    Task<IEnumerable<AccountOperation>> GetAccountOperationsAsync(Guid accountId);
    Task<IEnumerable<Account>> GetUserAccountsByUserIdAsync(Guid userId);
    Task<bool> OperationExists(Guid operationId);
    Task<Account?> GetPrimaryAccountByUserIdAsync(Guid userId);
    Task UpsertPushSubscriptionAsync(Guid userId, PushPlatform platform, PushAudience audience, string token);
    Task RemovePushSubscriptionAsync(Guid userId, string token);
    Task<IReadOnlyCollection<string>> GetPushTokensForAccountOwnersAsync(Guid accountId, PushAudience audience);
    Task<IReadOnlyCollection<string>> GetPushTokensByAudienceAsync(PushAudience audience);
}
