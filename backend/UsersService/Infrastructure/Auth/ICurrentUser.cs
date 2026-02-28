using UsersService.Domain.Enums;

namespace UsersService.Infrastructure.Auth;

public interface ICurrentUser
{
    Guid GetUserId();
    UserRole GetRole();
    bool IsAuthenticated();
}
