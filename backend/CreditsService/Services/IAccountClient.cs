using CreditsService.DTO;

public interface IAccountClient
{
    Task DepositAsync(Guid accountId, decimal amount);
    Task WithdrawAsync(Guid accountId, decimal amount);
    Task<bool> IsMyAccount(Guid accountId);
    Task<bool> IsAccountOwnedByUser(Guid accountId, Guid userId);
    Task TransferAsync(Guid fromAccountId, Guid toAccountId, decimal amount);
    Task<BankAccountInfoDto> GetMasterAccountAsync();
}