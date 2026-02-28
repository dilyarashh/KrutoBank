using UsersService.Domain.Entities;
using UsersService.DTOs;
using UsersService.DTOs.Enums;

namespace UsersService.Infrastructure.Repositories;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByPhoneAsync(string phone);
    Task<User?> GetByEmailAsync(string email);
    Task<(IEnumerable<User> Users, int TotalCount)> GetAllAsync(
        int page, 
        int pageSize, 
        UserSortOption? sortBy = null, 
        bool ascending = true);

    Task AddAsync(User user);
    Task UpdateAsync(User user);
}