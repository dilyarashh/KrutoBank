using AccountsService.DTO;

namespace AccountsService.Services
{
    public class UsersClient(HttpClient httpClient) : IUsersClient
    {
        private readonly HttpClient _httpClient = httpClient;

        public async Task<UserDto?> GetByPhoneAsync(string phone)
        {
            var response = await _httpClient.GetAsync($"/api/users/by-phone?phone={phone}");

            if (!response.IsSuccessStatusCode)
                return null;

            return await response.Content.ReadFromJsonAsync<UserDto>();
        }
    }
}
