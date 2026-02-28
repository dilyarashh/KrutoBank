using System.ComponentModel.DataAnnotations;

namespace CreditsService.Entities;

public class Loan
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid TariffId { get; set; }
    public decimal InitialAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime LastInterestApplicationDate { get; set; }
    public bool IsActive { get; set; } = true;

    public Tariff? Tariff { get; set; }
    public ICollection<LoanOperation>? Operations { get; set; }
}