using CreditsService.Entities;

namespace CreditsService.Repositories
{
    public interface ITariffRepository
    {
        Task<Tariff?> GetByIdAsync(Guid id);
        Task<Tariff?> GetByNameAsync(string name);
        Task<List<Tariff>> GetAllActiveAsync();
        Task<bool> ExistsByNameAsync(string name);
        void Add(Tariff tariff);
        void Update(Tariff tariff);
        Task SaveChangesAsync();
    }
}
