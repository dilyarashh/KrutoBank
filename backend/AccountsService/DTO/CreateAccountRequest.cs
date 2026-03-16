using AccountsService.Entities.Enums;

namespace AccountsService.DTO;

public class CreateAccountRequest
{
    public string? Name { get; set; }
    public Currency Currency { get; set; }
}
