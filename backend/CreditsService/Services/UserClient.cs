using System.Net.Http.Json;

public class UserClient(HttpClient httpClient) : IUserClient
{
    public async Task<bool> UserExists(Guid userId)
    {
        var response = await httpClient.GetAsync($"/api/users/{userId}");

        return response.IsSuccessStatusCode;
    }
}