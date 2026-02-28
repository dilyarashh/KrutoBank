namespace CreditsService.DTO;

public class CreateTariffDto
{
    public string Name { get; set; } = string.Empty;
    public decimal InterestRate { get; set; }
}