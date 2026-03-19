using System.ComponentModel.DataAnnotations;

namespace AuthService.Models;

public class LoginViewModel
{
    [Required(ErrorMessage = "Введите номер телефона")]
    public string Phone { get; set; } = string.Empty;

    [Required(ErrorMessage = "Введите пароль")]
    public string Password { get; set; } = string.Empty;

    public string ReturnUrl { get; set; } = "/";
    public string? Error { get; set; }
}
