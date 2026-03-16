namespace CreditsService.DTO
{
    public class RepayLoanDto
    {
        public Guid LoanId { get; set; }
        public decimal Amount { get; set; }
        public Guid AccountId { get; set; }
    }
}
