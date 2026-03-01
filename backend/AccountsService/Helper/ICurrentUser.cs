namespace AccountsService.Helper;

public interface ICurrentUser
{
    Guid GetUserId();
    string GetRole();
    bool IsAuthenticated();
}
