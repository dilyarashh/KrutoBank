using AccountsService.DTO;
using AccountsService.Entities;
using AccountsService.Entities.Enums;
using AccountsService.Errors.Exceptions;
using AccountsService.Helper;
using AccountsService.Repositories;

namespace AccountsService.Services;

public class AccountService(IAccountRepository accountRepository, ICurrentUser currentUser) : IAccountService
{
    private readonly IAccountRepository _accountRepository = accountRepository;
    private readonly ICurrentUser _currentUser = currentUser;

    public async Task<Account> CreateAccountAsync(CreateAccountRequest request)
    {
        var userId = _currentUser.GetUserId();
        
        var userAccounts = await _accountRepository.GetUserAccountsAsync(userId);
        var accountName = request.Name ?? $"Счет {userAccounts.Count() + 1}";

        var account = new Account
        {
            Id = Guid.NewGuid(),
            Name = accountName,
            Balance = 0,
            OpenedAt = DateTime.UtcNow,
            IsClosed = false
        };

        await _accountRepository.AddAsync(account);
        await _accountRepository.AddUserAccountAsync(userId, account.Id);

        return account;
    }

    public async Task CloseAccountAsync(Guid accountId)
    {
        var userId = _currentUser.GetUserId();

        var account = await _accountRepository.GetByIdAsync(accountId);
        if (account == null)
        {
            throw new NotFoundException("Счет не найден");
        }
            
        var userIsOwner = await _accountRepository.GetByIdForUserAsync(accountId, userId);
        if (userIsOwner == null)
        {
            throw new BadRequestException("Вы можете закрыть только свой счет");
        }

        if (account.IsClosed)
        {
            throw new BadRequestException("Счет уже закрыт");
        }

        var otherAccounts = (await _accountRepository.GetUserAccountsAsync(userId))
            .Where(a => a.Id != accountId && !a.IsClosed)
            .ToList();

        if (account.Balance > 0 && otherAccounts.Count != 0)
        {
            var target = otherAccounts.First();
            target.Balance += account.Balance;

            await _accountRepository.AddOperationAsync(new AccountOperation
            {
                Id = Guid.NewGuid(),
                AccountId = target.Id,
                Type = OperationType.Deposit,
                Amount = account.Balance,
                CreatedAt = DateTime.UtcNow
            });

            account.Balance = 0;
            await _accountRepository.UpdateAsync(target);
        }

        account.IsClosed = true;
        account.ClosedAt = DateTime.UtcNow;
        await _accountRepository.UpdateAsync(account);
    }
}