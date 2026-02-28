using CreditsService.DTO;

public interface ICreditService
{
    Task<TariffResponseDto> CreateTariff(CreateTariffDto dto);

    Task<LoanInfoDto> TakeLoan(CreateLoanDto dto);

    Task<LoanInfoDto> RepayLoan(RepayLoanDto dto);

    Task<List<LoanInfoDto>> GetUserLoans(Guid userId);

    Task<List<LoanOperationDto>> GetLoanOperations(Guid userId, Guid loanId);

    Task AccrueInterestForAll();
}