using System.Text.Json.Serialization;

namespace UsersService.DTOs.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum UserSortOption
{
    Created,
    LastName
}

