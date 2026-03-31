using UsersService.Application.DTOs.Internal;
using UsersService.Domain.Entities;
using UsersService.DTOs;
using UsersService.DTOs.Internal;

namespace UsersService.Services;

public interface IUserService
{
    Task<User> CreateUserAsync(CreateUserRequest dto);
    Task BlockUserAsync(Guid id);
    Task<UserDto?> GetById(Guid id);
    Task<UserDto?> GetMyself();
    Task<PagedResponse<UserDto>> GetAllAsync(PagedRequest pagedRequest);
    Task<UserDto?> GetByPhoneAsync(string phone);

    Task<InternalUserAuthDto?> GetInternalByIdAsync(Guid id);
    Task<InternalUserAuthDto?> GetInternalByPhoneAsync(string phone);

    Task<InternalUserLookupDto?> GetInternalLookupByIdAsync(Guid id);
    Task<InternalUserLookupDto?> GetInternalLookupByPhoneAsync(string phone);
}