namespace CreditsService.DTO
{
    public class CreateAutoPaymentDto
    {
        public Guid LoanId { get; set; }

        public Guid AccountId { get; set; }

        public decimal Amount { get; set; }

        public int IntervalMinutes { get; set; }
    }
}
