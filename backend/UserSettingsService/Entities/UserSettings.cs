namespace UserSettingsService.Entities
{
    public class UserSettings
    {
        public Guid UserId { get; set; }

        public string Theme { get; set; } = "light";

        public string HiddenAccountIdsJson { get; set; } = "[]";
    }
}
