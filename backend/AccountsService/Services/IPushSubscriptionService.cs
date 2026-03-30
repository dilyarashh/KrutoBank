using AccountsService.DTO;

namespace AccountsService.Services;

public interface IPushSubscriptionService
{
    Task RegisterAsync(RegisterPushSubscriptionRequest request);
    Task RemoveAsync(string token);
}
