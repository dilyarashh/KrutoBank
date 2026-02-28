namespace AccountsService.DTO;

public class OperationDto
{
    public DateTime CreatedAt { get; set; }
    public string Type { get; set; } = null!;
    public decimal Amount { get; set; }
}
