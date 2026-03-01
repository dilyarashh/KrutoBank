using System;

namespace AccountsService.DTO;

public class AccountDetailsDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public decimal Balance { get; set; }
    public DateTime OpenedAt { get; set; }
    public bool IsClosed { get; set; }
    public DateTime? ClosedAt { get; set; }
}