using AccountsService.Data;
using AccountsService.Entities;
using Microsoft.EntityFrameworkCore;

namespace AccountsService.Repositories;

public class AccountRepository(AccountsDbContext db) : IAccountRepository
{
    public async Task<Account> AddAsync(Account account)
    {
        db.Accounts.Add(account);
        await db.SaveChangesAsync();
        return account;
    }

    public async Task<Account?> GetByIdAsync(Guid accountId)
    {
        return await db.Accounts.FindAsync(accountId);
    }

    public async Task<Account?> GetByIdForUserAsync(Guid accountId, Guid userId)
    {
        var isOwner = await db.UserAccounts
            .AnyAsync(ua => ua.AccountId == accountId && ua.UserId == userId);

        if (!isOwner)
            return null;

        return await db.Accounts.FindAsync(accountId);
    }

    public async Task<IEnumerable<Account>> GetUserAccountsAsync(Guid userId)
    {
        var accountIds = await db.UserAccounts
            .Where(ua => ua.UserId == userId)
            .Select(ua => ua.AccountId)
            .ToListAsync();

        var accounts = await db.Accounts
            .Where(a => accountIds.Contains(a.Id) && !a.IsClosed)
            .ToListAsync();

        return accounts;
    }

    public async Task UpdateAsync(Account account)
    {
        db.Accounts.Update(account);
        await db.SaveChangesAsync();
    }

    public async Task AddOperationAsync(AccountOperation operation)
    {
        db.AccountOperations.Add(operation);
        await db.SaveChangesAsync();
    }

    public async Task AddUserAccountAsync(Guid userId, Guid accountId)
    {
        db.UserAccounts.Add(new UserAccount
        {
            UserId = userId,
            AccountId = accountId
        });
        await db.SaveChangesAsync();
    }
}