using UserSettingsService.Entities.Enums;

namespace UserSettingsService.Entities
{
    public class UserSettings
    {
        public Guid UserId { get; set; }

        public Theme Theme { get; set; } = Theme.Light;

        public string HiddenAccountIdsJson { get; set; } = "[]";
    }
}
