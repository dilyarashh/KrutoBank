namespace UserSettingsService.DTO
{
    public class UserSettingsDto
    {
        public string Theme { get; set; } = "light";
        public List<Guid> HiddenAccountIds { get; set; } = new();
    }
}
