using System.Text.Json.Serialization;

namespace UserSettingsService.Entities.Enums
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum Theme
    {
        Light = 0,
        Dark = 1
    }
}
