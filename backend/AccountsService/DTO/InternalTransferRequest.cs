namespace AccountsService.DTO
{
    public class InternalTransferRequest
    {
        public Guid FromAccountId { get; set; }
        public Guid ToAccountId { get; set; }
        public decimal Amount { get; set; }
    }
}
