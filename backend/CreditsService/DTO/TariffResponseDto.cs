namespace CreditsService.DTO
{
    public class TariffResponseDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal InterestRate { get; set; }
    }
}
