using CreditsService.Entities.Enums;

namespace CreditsService.Entities
{
    public class LoanOperation
    {
        public Guid Id { get; set; }
        public Guid LoanId { get; set; }
        public decimal Amount { get; set; }
        public DateTime OperationDate { get; set; } = DateTime.UtcNow;
        public LoanOperationType Type { get; set; }

        public Loan? Loan { get; set; }
    }
}
