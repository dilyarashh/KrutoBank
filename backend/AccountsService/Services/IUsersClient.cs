using AccountsService.DTO;

namespace AccountsService.Services
{
    public interface IUsersClient
    {
        Task<UserDto?> GetByPhoneAsync(string phone);
    }
}
