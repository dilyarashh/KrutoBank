using AccountsService.Data;
using AccountsService.DTO;
using AccountsService.Entities;
using AccountsService.Entities.Enums;
using Microsoft.EntityFrameworkCore;

namespace AccountsService.Repositories;

public class AccountRepository(AccountsDbContext db) : IAccountRepository
{
    public Task<Account> AddAsync(Account account)
    {
        db.Accounts.Add(account);
        return Task.FromResult(account);
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

        return await db.Accounts
            .Where(a => accountIds.Contains(a.Id))
            .ToListAsync(); 
    }

    public Task UpdateAsync(Account account)
    {
        db.Accounts.Update(account);
        return Task.CompletedTask;
    }

    public Task AddOperationAsync(AccountOperation operation)
    {
        db.AccountOperations.Add(operation);
        return Task.CompletedTask;
    }

    public Task AddUserAccountAsync(Guid userId, Guid accountId)
    {
        db.UserAccounts.Add(new UserAccount
        {
            UserId = userId,
            AccountId = accountId
        });

        return Task.CompletedTask;
    }

    public async Task SaveChangesAsync()
    {
        await db.SaveChangesAsync();
    }
    
    public async Task<IEnumerable<AccountOperation>> GetAccountOperationsForUserAsync(
        Guid accountId,
        Guid userId)
    {
        var isOwner = await db.UserAccounts
            .AnyAsync(ua => ua.AccountId == accountId && ua.UserId == userId);

        if (!isOwner)
            return [];

        return await db.AccountOperations
            .Where(o => o.AccountId == accountId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }
    
    public async Task<PagedResult<UserAccountDto>> GetAllUserAccountsAsync(
        bool? onlyOpened,
        int page,
        int pageSize)
    {
        var query = db.UserAccounts
            .AsNoTracking()
            .Include(x => x.Account)
            .AsQueryable();

        if (onlyOpened == true)
            query = query.Where(x => !x.Account.IsClosed);

        if (onlyOpened == false)
            query = query.Where(x => x.Account.IsClosed);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderBy(x => x.Account.OpenedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new UserAccountDto
            {
                UserId = x.UserId,
                AccountId = x.AccountId,
                AccountName = x.Account.Name,
                Balance = x.Account.Balance,
                Currency = x.Account.Currency,
                IsClosed = x.Account.IsClosed
            })
            .ToListAsync();

        return new PagedResult<UserAccountDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }
    
    public async Task<IEnumerable<AccountOperation>> GetAccountOperationsAsync(Guid accountId)
    {
        return await db.AccountOperations
            .Where(o => o.AccountId == accountId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Account>> GetUserAccountsByUserIdAsync(Guid userId)
    {
        var accountIds = await db.UserAccounts
            .Where(ua => ua.UserId == userId)
            .Select(ua => ua.AccountId)
            .ToListAsync();

        return await db.Accounts
            .Where(a => accountIds.Contains(a.Id))
            .ToListAsync();
    }

    public async Task<bool> OperationExists(Guid operationId)
    {
        return await db.AccountOperations
            .AnyAsync(o => o.Id == operationId);
    }

    public async Task<Account?> GetPrimaryAccountByUserIdAsync(Guid userId)
    {
        var accountIds = await db.UserAccounts
            .Where(ua => ua.UserId == userId)
            .Select(ua => ua.AccountId)
            .ToListAsync();

        return await db.Accounts
            .Where(a => accountIds.Contains(a.Id) && !a.IsClosed)
            .OrderBy(a => a.OpenedAt)
            .FirstOrDefaultAsync();
    }

    public async Task UpsertPushSubscriptionAsync(Guid userId, PushPlatform platform, PushAudience audience, string token)
    {
        var existing = await db.PushSubscriptions
            .FirstOrDefaultAsync(x => x.Token == token);

        if (existing is null)
        {
            db.PushSubscriptions.Add(new PushSubscription
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Platform = platform,
                Audience = audience,
                Token = token,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });

            return;
        }

        existing.UserId = userId;
        existing.Platform = platform;
        existing.Audience = audience;
        existing.UpdatedAt = DateTime.UtcNow;
    }

    public async Task RemovePushSubscriptionAsync(Guid userId, string token)
    {
        var existing = await db.PushSubscriptions
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Token == token);

        if (existing is not null)
        {
            db.PushSubscriptions.Remove(existing);
        }
    }

    public async Task<IReadOnlyCollection<string>> GetPushTokensForAccountOwnersAsync(Guid accountId, PushAudience audience)
    {
        var ownerIds = await db.UserAccounts
            .Where(x => x.AccountId == accountId)
            .Select(x => x.UserId)
            .ToListAsync();

        return await db.PushSubscriptions
            .Where(x => ownerIds.Contains(x.UserId) && x.Audience == audience)
            .Select(x => x.Token)
            .Distinct()
            .ToListAsync();
    }

    public async Task<IReadOnlyCollection<string>> GetPushTokensByAudienceAsync(PushAudience audience)
    {
        return await db.PushSubscriptions
            .Where(x => x.Audience == audience)
            .Select(x => x.Token)
            .Distinct()
            .ToListAsync();
    }
}
