using CreditsService.Entities;

namespace CreditsService.Repositories
{
    public interface ILoanOperationRepository
    {
        Task<List<LoanOperation>> GetByLoanIdAsync(Guid loanId);
        void Add(LoanOperation operation);
        void AddRange(IEnumerable<LoanOperation> operations);
        Task SaveChangesAsync();
    }
}
