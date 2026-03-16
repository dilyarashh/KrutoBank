namespace CreditsService.Entities
{
    public class AutoPayment
    {
        public Guid Id { get; set; }

        public Guid LoanId { get; set; }

        public Guid AccountId { get; set; }

        public decimal Amount { get; set; }

        public int IntervalMinutes { get; set; }

        public DateTime NextExecutionDate { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; }

        public Loan Loan { get; set; } = null!;
    }
}
