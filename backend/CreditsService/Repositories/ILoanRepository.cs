using CreditsService.Entities;
using Microsoft.EntityFrameworkCore.Storage;

namespace CreditsService.Repositories
{
    public interface ILoanRepository
    {
        Task<Loan?> GetByIdAsync(Guid id);
        Task<Loan?> GetByIdWithTariffAsync(Guid id);
        Task<List<Loan>> GetUserLoansAsync(Guid userId);
        Task<List<Loan>> GetActiveLoansWithTariffAsync();
        Task<bool> UserHasLoanAsync(Guid userId, Guid loanId);
        void Add(Loan loan);
        void Update(Loan loan);
        Task SaveChangesAsync();
        Task<IDbContextTransaction> BeginTransactionAsync();
    }
}
