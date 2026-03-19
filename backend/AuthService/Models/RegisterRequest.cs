using System.ComponentModel.DataAnnotations;
using AuthService.Entities;

namespace AuthService.Models;

public class RegisterRequest
{
    [Required]
    [MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string LastName { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string MiddleName { get; set; } = string.Empty;

    [Required]
    [RegularExpression(@"^\+?\d{10,15}$")]
    public string Phone { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public DateOnly Birthday { get; set; }

    [Required]
    [MinLength(8)]
    public string Password { get; set; } = string.Empty;

    [Required]
    [EnumDataType(typeof(UserRole))]
    public UserRole Role { get; set; }
}
