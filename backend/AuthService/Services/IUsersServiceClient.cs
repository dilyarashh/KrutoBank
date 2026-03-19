using AuthService.Models.Internal;
using AuthService.Models;

namespace AuthService.Services;

public interface IUsersServiceClient
{
    Task<InternalUserAuthDto?> GetByPhoneAsync(string phone, CancellationToken ct = default);
    Task<InternalUserAuthDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<(bool Success, Guid? UserId, string? Error)> CreateUserAsync(RegisterRequest request, string passwordHash, CancellationToken ct = default);
    Task<bool> UpdatePasswordHashAsync(Guid id, string passwordHash, CancellationToken ct = default);
}
