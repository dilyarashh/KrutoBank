using Microsoft.EntityFrameworkCore;
using UserSettingsService.Data;
using UserSettingsService.Entities;

namespace UserSettingsService.Repositories
{
    public class UserSettingsRepository(UserSettingsDbContext db)
    {
        public async Task<UserSettings?> GetAsync(Guid userId)
        {
            return await db.UserSettings.FindAsync(userId);
        }

        public async Task AddAsync(UserSettings settings)
        {
            await db.UserSettings.AddAsync(settings);
        }

        public Task UpdateAsync(UserSettings settings)
        {
            db.UserSettings.Update(settings);
            return Task.CompletedTask;
        }

        public async Task SaveChangesAsync()
        {
            await db.SaveChangesAsync();
        }
    }
}
