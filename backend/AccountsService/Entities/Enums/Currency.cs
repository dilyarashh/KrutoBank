using System.Text.Json.Serialization;

namespace AccountsService.Entities.Enums
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum Currency
    {
        RUB = 0,
        USD = 1,
        EUR = 2
    }
}
