using UsersService.Domain.Enums;

namespace UsersService.DTOs.Internal;

public class InternalCreateUserRequest
{
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public required string MiddleName { get; set; }
    public required string Phone { get; set; }
    public required string Email { get; set; }
    public DateOnly Birthday { get; set; }
    public UserRole Role { get; set; }
    public required string PasswordHash { get; set; }
}
