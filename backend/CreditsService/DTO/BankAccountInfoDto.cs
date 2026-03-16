using CreditsService.Entities.Enums;

namespace CreditsService.DTO
{
    public class BankAccountInfoDto
    {
        public Guid AccountId { get; set; }

        public decimal Balance { get; set; }

        public Currency Currency { get; set; }
    }
}
