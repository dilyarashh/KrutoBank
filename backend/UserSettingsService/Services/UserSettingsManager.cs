using System.Text.Json;
using UserSettingsService.DTO;
using UserSettingsService.Entities;
using UserSettingsService.Entities.Enums;
using UserSettingsService.Repositories;

namespace UserSettingsService.Services;

public class UserSettingsManager(UserSettingsRepository repo)
{
    public async Task<UserSettingsDto> GetOrCreateAsync(Guid userId)
    {
        var settings = await repo.GetAsync(userId);

        if (settings == null)
        {
            settings = new UserSettings
            {
                UserId = userId,
                Theme = Theme.Light,
                HiddenAccountIdsJson = "[]"
            };

            await repo.AddAsync(settings);
            await repo.SaveChangesAsync();
        }

        return new UserSettingsDto
        {
            Theme = settings.Theme,
            HiddenAccountIds = JsonSerializer.Deserialize<List<Guid>>(settings.HiddenAccountIdsJson) ?? []
        };
    }

    public async Task UpdateTheme(Guid userId, Theme theme)
    {
        var settings = await repo.GetAsync(userId) ?? new UserSettings { UserId = userId };

        settings.Theme = theme;

        await repo.UpdateAsync(settings);
        await repo.SaveChangesAsync();
    }

    public async Task UpdateHiddenAccounts(Guid userId, List<Guid> accountIds)
    {
        var settings = await repo.GetAsync(userId) ?? new UserSettings { UserId = userId };

        settings.HiddenAccountIdsJson = JsonSerializer.Serialize(accountIds);

        await repo.UpdateAsync(settings);
        await repo.SaveChangesAsync();
    }
}