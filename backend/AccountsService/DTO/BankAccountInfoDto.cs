using AccountsService.Entities.Enums;

namespace AccountsService.DTO
{
    public class BankAccountInfoDto
    {
        public Guid AccountId { get; set; }

        public decimal Balance { get; set; }

        public Currency Currency { get; set; }
    }
}
