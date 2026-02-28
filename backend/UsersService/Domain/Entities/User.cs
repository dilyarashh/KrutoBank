using UsersService.Domain.Enums;

namespace UsersService.Domain.Entities;

public class User
{
    public required Guid Id { get; set; }

    public required string FirstName { get; set; } //Имя
    
    public required string LastName { get; set; } //Фамилия
    
    public required string MiddleName { get; set; } //Отчество
    
    public required string Phone { get; set; }
    public string? Email { get; set; }
    
    public required DateOnly Birthday { get; set; }
    
    public required string HashPassword { get; set; }
    public UserRole Role { get; set; }
    public required bool IsBlocked { get; set; } = false;
    
    public required DateTime Created { get; set; }
    
    public DateTime? Updated { get; set; }
}