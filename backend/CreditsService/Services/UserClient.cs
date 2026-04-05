using System.Net.Http.Json;

public class UserClient(HttpClient httpClient) : IUserClient
{
    public async Task<bool> UserExists(Guid userId)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, $"/api/internal/users/{userId}");
        request.Headers.Add("X-Internal-Api-Key", "KRUTOBANK_INTERNAL_KEY_2026");

        var response = await httpClient.SendAsync(request);

        return response.IsSuccessStatusCode;
    }
}
