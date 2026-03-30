using System.Text.Json.Serialization;

namespace AccountsService.Entities.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum PushPlatform
{
    Web = 0,
    Android = 1
}
