using CreditsService.DTO;

public interface IUserClient
{
    Task<bool> UserExists(Guid userId);
}