using UserSettingsService.Entities.Enums;

namespace UserSettingsService.DTO
{
    public class UserSettingsDto
    {
        public Theme Theme { get; set; } = Theme.Light;
        public List<Guid> HiddenAccountIds { get; set; } = new();
    }
}
