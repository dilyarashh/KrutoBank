using AccountsService.DTO;
using System.Net.Http.Json;

namespace AccountsService.Services
{
    public class UsersClient(HttpClient httpClient) : IUsersClient
    {
        private readonly HttpClient _httpClient = httpClient;
        private const string InternalHeader = "X-Internal-Api-Key";

        public async Task<UserDto?> GetByPhoneAsync(string phone)
        {
            using var request = new HttpRequestMessage(
                HttpMethod.Get,
                $"/api/users/internal/lookup/by-phone?phone={Uri.EscapeDataString(phone)}");

            request.Headers.Add(InternalHeader, "KRUTOBANK_INTERNAL_KEY_2026");

            var response = await _httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
                return null;

            var internalUser = await response.Content.ReadFromJsonAsync<InternalUserLookupDto>();

            if (internalUser == null)
                return null;

            return new UserDto
            {
                Id = internalUser.Id,
                Phone = internalUser.Phone
            };
        }

        private class InternalUserLookupDto
        {
            public Guid Id { get; set; }
            public string Phone { get; set; } = default!;
            public string Role { get; set; } = default!;
            public bool IsBlocked { get; set; }
        }
    }
}