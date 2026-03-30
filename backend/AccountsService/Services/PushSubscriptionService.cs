using AccountsService.DTO;
using AccountsService.Entities.Enums;
using AccountsService.Errors.Exceptions;
using AccountsService.Helper;
using AccountsService.Repositories;

namespace AccountsService.Services;

public class PushSubscriptionService(
    IAccountRepository accountRepository,
    ICurrentUser currentUser) : IPushSubscriptionService
{
    public async Task RegisterAsync(RegisterPushSubscriptionRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Token))
        {
            throw new BadRequestException("Push token обязателен");
        }

        if (request.Audience == PushAudience.Employee &&
            !string.Equals(currentUser.GetRole(), "Employee", StringComparison.OrdinalIgnoreCase))
        {
            throw new ForbiddenException("Подписка на уведомления сотрудника доступна только сотруднику");
        }

        await accountRepository.UpsertPushSubscriptionAsync(
            currentUser.GetUserId(),
            request.Platform,
            request.Audience,
            request.Token);
        await accountRepository.SaveChangesAsync();
    }

    public async Task RemoveAsync(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            throw new BadRequestException("Push token обязателен");
        }

        await accountRepository.RemovePushSubscriptionAsync(currentUser.GetUserId(), token);
        await accountRepository.SaveChangesAsync();
    }
}
