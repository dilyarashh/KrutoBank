namespace CreditsService.DTO
{
    public class CreateLoanDto
    {
        public Guid UserId { get; set; }
        public string TariffName { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }
}
