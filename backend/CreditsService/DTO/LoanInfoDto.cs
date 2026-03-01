namespace CreditsService.DTO
{
    public class LoanInfoDto
    {
        public Guid LoanId { get; set; }
        public decimal InitialAmount { get; set; }
        public decimal RemainingAmount { get; set; }
        public string TariffName { get; set; } = string.Empty;
        public decimal InterestRate { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }
}
