namespace CreditsService.DTO
{
    public class CreditScoreDto
    {
        public Guid UserId { get; set; }

        public int Score { get; set; }

        public int ActiveLoans { get; set; }

        public int ClosedLoans { get; set; }

        public int OverduePayments { get; set; }
    }
}
