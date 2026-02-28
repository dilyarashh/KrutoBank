using UsersService.Domain.Entities;
using UsersService.DTOs;

namespace UsersService.Services;

public interface IUserService
{
    Task<User> CreateUserAsync(CreateUserRequest dto);
    Task BlockUserAsync(Guid id);
    Task<UserDto?> GetById(Guid id);
    Task<UserDto?> GetMyself();
    Task<PagedResponse<UserDto>> GetAllAsync(PagedRequest pagedRequest);
}