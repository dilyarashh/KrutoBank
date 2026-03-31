namespace UsersService.Application.DTOs.Internal
{
    public class InternalUserLookupDto
    {
        public Guid Id { get; set; }
        public required string Phone { get; set; }
        public required string Role { get; set; }
        public bool IsBlocked { get; set; }
    }
}
