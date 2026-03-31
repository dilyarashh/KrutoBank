using System.Net;
using System.Net.Http.Json;
using AuthService.Models;
using AuthService.Models.Internal;

namespace AuthService.Services;

public class UsersServiceClient(HttpClient httpClient, IConfiguration configuration) : IUsersServiceClient
{
    private const string InternalHeader = "X-Internal-Api-Key";

    public async Task<InternalUserAuthDto?> GetByPhoneAsync(string phone, CancellationToken ct = default)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, $"api/users/internal/by-phone?phone={Uri.EscapeDataString(phone)}");
        AddInternalHeader(request);

        using var response = await httpClient.SendAsync(request, ct);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<InternalUserAuthDto>(cancellationToken: ct);
    }

    public async Task<InternalUserAuthDto?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, $"api/users/internal/{id}");
        AddInternalHeader(request);

        using var response = await httpClient.SendAsync(request, ct);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<InternalUserAuthDto>(cancellationToken: ct);
    }

    public async Task<(bool Success, Guid? UserId, string? Error)> CreateUserAsync(RegisterRequest request, string passwordHash, CancellationToken ct = default)
    {
        var payload = new InternalCreateUserRequest
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            MiddleName = request.MiddleName,
            Phone = request.Phone,
            Email = request.Email,
            Birthday = request.Birthday,
            Role = request.Role.ToString(),
            PasswordHash = passwordHash
        };

        using var httpRequest = new HttpRequestMessage(HttpMethod.Post, "api/internal/users")
        {
            Content = JsonContent.Create(payload)
        };

        AddInternalHeader(httpRequest);

        using var response = await httpClient.SendAsync(httpRequest, ct);

        if (response.IsSuccessStatusCode)
        {
            var userId = await response.Content.ReadFromJsonAsync<Guid>(cancellationToken: ct);
            return (true, userId, null);
        }

        var error = await response.Content.ReadAsStringAsync(ct);
        return (false, null, string.IsNullOrWhiteSpace(error) ? "Ошибка создания пользователя" : error);
    }

    public async Task<bool> UpdatePasswordHashAsync(Guid id, string passwordHash, CancellationToken ct = default)
    {
        using var request = new HttpRequestMessage(HttpMethod.Patch, $"api/internal/users/{id}/password")
        {
            Content = JsonContent.Create(new InternalUpdatePasswordRequest
            {
                PasswordHash = passwordHash
            })
        };

        AddInternalHeader(request);

        using var response = await httpClient.SendAsync(request, ct);
        return response.IsSuccessStatusCode;
    }

    private void AddInternalHeader(HttpRequestMessage request)
    {
        var key = configuration["UsersService:InternalApiKey"];
        if (!string.IsNullOrWhiteSpace(key))
        {
            request.Headers.Add(InternalHeader, key);
        }
    }
}
