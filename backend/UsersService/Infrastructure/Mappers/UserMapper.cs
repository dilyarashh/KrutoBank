using UsersService.Domain.Entities;
using UsersService.DTOs;

namespace UsersService.Infrastructure.Mappers;

public static class UserMapper
{
    public static UserDto ToDto(this User user)
    {
        return new UserDto
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            MiddleName = user.MiddleName,
            Phone = user.Phone,
            Email = user.Email,
            Birthday = user.Birthday,
            Role = user.Role,
            IsBlocked = user.IsBlocked
        };
    }
}