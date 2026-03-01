using CreditsService.Data;
using CreditsService.Entities;
using Microsoft.EntityFrameworkCore;

namespace CreditsService.Repositories
{
    public class TariffRepository : ITariffRepository
    {
        private readonly CreditsDbContext _dbContext;

        public TariffRepository(CreditsDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Tariff?> GetByIdAsync(Guid id)
        {
            return await _dbContext.Tariffs.FindAsync(id);
        }

        public async Task<Tariff?> GetByNameAsync(string name)
        {
            return await _dbContext.Tariffs
                .FirstOrDefaultAsync(t => t.Name == name && t.IsActive);
        }

        public async Task<List<Tariff>> GetAllActiveAsync()
        {
            return await _dbContext.Tariffs
                .Where(t => t.IsActive)
                .ToListAsync();
        }

        public async Task<bool> ExistsByNameAsync(string name)
        {
            return await _dbContext.Tariffs
                .AnyAsync(t => t.Name == name && t.IsActive);
        }

        public void Add(Tariff tariff)
        {
            _dbContext.Tariffs.Add(tariff);
        }

        public void Update(Tariff tariff)
        {
            _dbContext.Tariffs.Update(tariff);
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }
    }
}
