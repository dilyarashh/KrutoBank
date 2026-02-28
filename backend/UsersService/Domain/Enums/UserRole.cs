using System.Text.Json.Serialization;

namespace UsersService.Domain.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum UserRole
{
    Client,
    Employee
}
