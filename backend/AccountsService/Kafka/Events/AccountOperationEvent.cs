using AccountsService.Entities.Enums;

namespace AccountsService.Kafka.Events
{
    public class AccountOperationEvent
    {
        public Guid AccountId { get; set; }
        public Guid OperationId { get; set; }
        public decimal Amount { get; set; }
        public string Type { get; set; } = default!;
        public string Currency { get; set; } = default!;
    }
}
