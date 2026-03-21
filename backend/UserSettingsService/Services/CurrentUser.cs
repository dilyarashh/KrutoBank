using System.Security.Claims;

namespace UserSettingsService.Services
{
    public class CurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
    {
        public Guid GetUserId()
        {
            var userId = httpContextAccessor.HttpContext?.User
                ?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            return Guid.Parse(userId!);
        }
    }
}
