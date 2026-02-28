using CreditsService.Data;
using CreditsService.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace CreditsService.Repositories
{
    public class LoanRepository : ILoanRepository
    {
        private readonly CreditsDbContext _dbContext;

        public LoanRepository(CreditsDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Loan?> GetByIdAsync(Guid id)
        {
            return await _dbContext.Loans.FindAsync(id);
        }

        public async Task<Loan?> GetByIdWithTariffAsync(Guid id)
        {
            return await _dbContext.Loans
                .Include(l => l.Tariff)
                .FirstOrDefaultAsync(l => l.Id == id);
        }

        public async Task<List<Loan>> GetUserLoansAsync(Guid userId)
        {
            return await _dbContext.Loans
                .Include(l => l.Tariff)
                .Where(l => l.UserId == userId)
                .OrderByDescending(l => l.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Loan>> GetActiveLoansWithTariffAsync()
        {
            return await _dbContext.Loans
                .Include(l => l.Tariff)
                .Where(l => l.IsActive)
                .ToListAsync();
        }

        public async Task<bool> UserHasLoanAsync(Guid userId, Guid loanId)
        {
            return await _dbContext.Loans
                .AnyAsync(l => l.Id == loanId && l.UserId == userId);
        }

        public void Add(Loan loan)
        {
            _dbContext.Loans.Add(loan);
        }

        public void Update(Loan loan)
        {
            _dbContext.Loans.Update(loan);
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }

        public async Task<IDbContextTransaction> BeginTransactionAsync()
        {
            return await _dbContext.Database.BeginTransactionAsync();
        }
    }
}
