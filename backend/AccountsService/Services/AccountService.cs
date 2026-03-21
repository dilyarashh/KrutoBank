using AccountsService.DTO;
using AccountsService.Entities;
using AccountsService.Entities.Enums;
using AccountsService.Errors.Exceptions;
using AccountsService.Helper;
using AccountsService.Kafka;
using AccountsService.Kafka.Events;
using AccountsService.Repositories;
using System.Security.Principal;

namespace AccountsService.Services;

public class AccountService(IAccountRepository accountRepository, ICurrentUser currentUser, CurrencyService currencyService, KafkaProducer kafkaProducer) : IAccountService
{
    private readonly IAccountRepository _accountRepository = accountRepository;
    private readonly ICurrentUser _currentUser = currentUser;
    private readonly CurrencyService _currencyService = currencyService;
    private readonly KafkaProducer _kafkaProducer = kafkaProducer;

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
            Currency = request.Currency,
            OpenedAt = DateTime.UtcNow,
            IsClosed = false
        };

        await _accountRepository.AddAsync(account);
        await _accountRepository.AddUserAccountAsync(userId, account.Id);

        await _accountRepository.SaveChangesAsync();
        
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

            await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
            {
                OperationId = Guid.NewGuid(),
                AccountId = account.Id,
                Amount = account.Balance,
                Type = "Withdraw"
            });

            await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
            {
                OperationId = Guid.NewGuid(),
                AccountId = target.Id,
                Amount = account.Balance,
                Type = "Deposit"
            });
        }

        account.IsClosed = true;
        account.ClosedAt = DateTime.UtcNow;

        await _accountRepository.UpdateAsync(account);
        await _accountRepository.SaveChangesAsync();
    }

    public async Task<bool> DepositAsync(Guid accountId, decimal amount)
    {
        if (amount <= 0)
            throw new BadRequestException("Сумма должна быть больше нуля");

        var userId = _currentUser.GetUserId();
        
        var account = await _accountRepository.GetByIdAsync(accountId);
        if (account == null)
        {
            throw new NotFoundException("Счет не найден");
        }

        if (account.IsClosed)
        {
            throw new BadRequestException("Счет закрыт");
        }

        await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
        {
            OperationId = Guid.NewGuid(),
            AccountId = account.Id,
            Amount = amount,
            Type = "Deposit"
        });

        return true;
    }

    public async Task TransferAsync(TransferRequest request)
    {
        if (request.Amount <= 0)
        {
            throw new BadRequestException("Сумма должна быть больше нуля");
        }

        var userId = _currentUser.GetUserId();

        var from = await _accountRepository.GetByIdForUserAsync(request.FromAccountId, userId);

        if (from == null)
        {
            throw new BadRequestException("Вы можете переводить деньги только со своего счета");
        }

        var to = await _accountRepository.GetByIdAsync(request.ToAccountId);

        if (to == null)
        {
            throw new NotFoundException("Счет назначения не найден");
        }

        if (from.Balance < request.Amount)
        {
            throw new BadRequestException("Недостаточно средств");
        }

        if (from.Id == BankAccounts.MasterAccountId && from.Balance < request.Amount)
        {
            throw new BadRequestException("Недостаточно средств на мастер-счете банка");
        }

        decimal depositAmount;

        if (from.Currency != to.Currency)
        {
            depositAmount = await _currencyService.Convert(
                request.Amount,
                from.Currency.ToString(),
                to.Currency.ToString());
        }
        else
        {
            depositAmount = request.Amount;
        }

        await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
        {
            OperationId = Guid.NewGuid(),
            AccountId = from.Id,
            Amount = request.Amount,
            Type = "Withdraw"
        });

        await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
        {
            OperationId = Guid.NewGuid(),
            AccountId = to.Id,
            Amount = depositAmount,
            Type = "Deposit"
        });
    }

    public async Task<bool> WithdrawAsync(Guid accountId, decimal amount)
    {
        if (amount <= 0)
            throw new BadRequestException("Сумма должна быть больше нуля");

        var userId = _currentUser.GetUserId();

        var account = await _accountRepository.GetByIdAsync(accountId);
        if (account == null)
        {
            throw new NotFoundException("Счет не найден");
        }
        
        var userIsOwner = await _accountRepository.GetByIdForUserAsync(accountId, userId);
        if (userIsOwner == null)
        {
            throw new BadRequestException("Вы можете снять деньги только со своего счёта");
        }

        if (account.IsClosed)
        {
            throw new BadRequestException("Счет закрыт");
        }

        if (account.Balance < amount)
        {
            throw new BadRequestException("Недостаточно средств");
        }

        await _kafkaProducer.SendAsync("account-operations", new AccountOperationEvent
        {
            OperationId = Guid.NewGuid(),
            AccountId = account.Id,
            Amount = amount,
            Type = "Withdraw"
        });

        return true;
    }

    public async Task<AccountDetailsDto> GetMyAccountAsync(Guid accountId)
    {
        var userId = _currentUser.GetUserId();

        var account = await _accountRepository.GetByIdForUserAsync(accountId, userId);
        if (account == null)
            throw new BadRequestException("Вы можете получить информацию только по своему счёту");

        return new()
        {
            Id = account.Id,
            Name = account.Name,
            Balance = account.Balance,
            OpenedAt = account.OpenedAt,
            IsClosed = account.IsClosed,
            ClosedAt = account.ClosedAt
        };
    }

    public async Task<AccountDetailsDto> GetAccountAsync(Guid accountId)
    {
        var account = await _accountRepository.GetByIdAsync(accountId);
        if (account == null)
            throw new NotFoundException("Счет не найден");

        return new()
        {
            Id = account.Id,
            Name = account.Name,
            Balance = account.Balance,
            OpenedAt = account.OpenedAt,
            IsClosed = account.IsClosed,
            ClosedAt = account.ClosedAt
        };
    }

    public async Task<IEnumerable<AccountOperation>> GetMyAccountHistoryAsync(Guid accountId)
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
            throw new BadRequestException("Вы можете получить историю только своего счёта");
        }

        return await _accountRepository.GetAccountOperationsForUserAsync(accountId, userId);
    }


    public async Task<PagedResult<UserAccountDto>> GetAllUserAccountsAsync(
        bool? onlyOpened,
        int page,
        int pageSize)
    {
        if (page <= 0) page = 1;
        if (pageSize <= 0 || pageSize > 100) pageSize = 10;

        return await _accountRepository
            .GetAllUserAccountsAsync(onlyOpened, page, pageSize);
    }
    
    public async Task<IEnumerable<AccountOperation>> GetAccountHistoryAsync(Guid accountId)
    {
        var account = await _accountRepository.GetByIdAsync(accountId);
        if (account == null)
            throw new NotFoundException("Счет не найден");

        return await _accountRepository.GetAccountOperationsAsync(accountId);
    }
    
    public async Task<IEnumerable<UserAccountDto>> GetMyAccountsAsync(bool? onlyOpened)
    {
        var userId = _currentUser.GetUserId();

        var accounts = await _accountRepository.GetUserAccountsAsync(userId);

        if (onlyOpened == true)
            accounts = accounts.Where(a => !a.IsClosed);

        if (onlyOpened == false)
            accounts = accounts.Where(a => a.IsClosed);

        return accounts.Select(a => new UserAccountDto
        {
            UserId = userId,
            AccountId = a.Id,
            AccountName = a.Name,
            Balance = a.Balance,
            Currency = a.Currency,
            IsClosed = a.IsClosed
        });
    }
    
    public async Task<IEnumerable<UserAccountDto>> GetUserAccountsByUserIdAsync(
        Guid userId,
        bool? onlyOpened)
    {
        var accounts = await _accountRepository.GetUserAccountsByUserIdAsync(userId);

        if (onlyOpened == true)
            accounts = accounts.Where(a => !a.IsClosed);

        if (onlyOpened == false)
            accounts = accounts.Where(a => a.IsClosed);

        return accounts.Select(a => new UserAccountDto
        {
            UserId = userId,
            AccountId = a.Id,
            AccountName = a.Name,
            Balance = a.Balance,
            Currency = a.Currency,
            IsClosed = a.IsClosed
        });
    }

    public async Task<BankAccountInfoDto> GetMasterAccountInfoAsync()
    {
        var account = await _accountRepository.GetByIdAsync(BankAccounts.MasterAccountId);

        if (account == null)
        {
            throw new NotFoundException("Мастер-счет банка не найден");
        }

        return new BankAccountInfoDto
        {
            AccountId = account.Id,
            Balance = account.Balance,
            Currency = account.Currency
        };
    }
}