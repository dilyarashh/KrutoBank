using CreditsService.Data;
using CreditsService.Entities;
using Microsoft.EntityFrameworkCore;

namespace CreditsService.Repositories
{
    public class LoanOperationRepository : ILoanOperationRepository
    {
        private readonly CreditsDbContext _dbContext;

        public LoanOperationRepository(CreditsDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<LoanOperation>> GetByLoanIdAsync(Guid loanId)
        {
            return await _dbContext.LoanOperations
                .Where(o => o.LoanId == loanId)
                .OrderByDescending(o => o.OperationDate)
                .ToListAsync();
        }

        public void Add(LoanOperation operation)
        {
            _dbContext.LoanOperations.Add(operation);
        }

        public void AddRange(IEnumerable<LoanOperation> operations)
        {
            _dbContext.LoanOperations.AddRange(operations);
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }
    }
}
