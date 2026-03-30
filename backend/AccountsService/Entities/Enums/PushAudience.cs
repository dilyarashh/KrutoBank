using System.Text.Json.Serialization;

namespace AccountsService.Entities.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum PushAudience
{
    Client = 0,
    Employee = 1
}
