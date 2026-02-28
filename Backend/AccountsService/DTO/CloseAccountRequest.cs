using System;

namespace AccountsService.DTO;

public class CloseAccountRequest
{
    public Guid AccountId { get; set; }
}