namespace CreditsService.DTO
{
    public class LoanOperationDto
    {
        public Guid OperationId { get; set; }
        public decimal Amount { get; set; }
        public DateTime OperationDate { get; set; }
        public string OperationType { get; set; } = string.Empty;
    }
}
