namespace CreditsService.DTO
{
    public class CreateLoanDto
    {
        public string TariffName { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public Guid AccountId { get; set; }
    }
}
