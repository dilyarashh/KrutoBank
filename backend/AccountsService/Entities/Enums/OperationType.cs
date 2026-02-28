using System.Text.Json.Serialization;

namespace AccountsService.Entities.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum OperationType
{
    Deposit,
    Withdraw,
}