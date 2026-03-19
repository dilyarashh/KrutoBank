using System.ComponentModel.DataAnnotations;

namespace AuthService.Models.Passwords;

public class SetInitialPasswordRequest
{
    [Required]
    public Guid UserId { get; set; }

    [Required]
    [MinLength(8)]
    public string NewPassword { get; set; } = string.Empty;
}
