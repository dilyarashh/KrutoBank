using UsersService.Domain.Enums;

namespace UsersService.DTOs;

public class UserDto
{
    public required Guid Id { get; set; }

    public required string FirstName { get; set; }
    public required  string LastName { get; set; }
    public required  string MiddleName { get; set; }
    public required  string Phone { get; set; }
    public string? Email { get; set; } 
    public DateOnly Birthday { get; set; }
    public UserRole Role { get; set; }
    public bool IsBlocked { get; set; }
}