namespace CreditsService.Helper
{
    public interface ICurrentUser
    {
        Guid GetUserId();
        string GetRole();
        bool IsAuthenticated();
    }
}
