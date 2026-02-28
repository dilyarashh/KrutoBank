using Microsoft.EntityFrameworkCore;
using UsersService.Domain.Entities;
using UsersService.DTOs.Enums;

namespace UsersService.Infrastructure.Repositories;

public class UserRepository(UsersDbContext db) : IUserRepository
{
    public async Task<User?> GetByIdAsync(Guid id)
    {
        return await db.Users.FindAsync(id);
    }

    public async Task<User?> GetByPhoneAsync(string phone)
    {
        return await db.Users.FirstOrDefaultAsync(u => u.Phone == phone);
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        return await db.Users.FirstOrDefaultAsync(u => u.Email == email);
    }

    public async Task<(IEnumerable<User> Users, int TotalCount)> GetAllAsync(
        int page, int pageSize, UserSortOption? sortBy = null, bool ascending = true)
    {
        IQueryable<User> query = db.Users;

        query = sortBy switch
        {
            UserSortOption.LastName => ascending ? query.OrderBy(u => u.LastName) : query.OrderByDescending(u => u.LastName),
            UserSortOption.Created => ascending ? query.OrderBy(u => u.Created) : query.OrderByDescending(u => u.Created),
            _ => query.OrderBy(u => u.Created)
        };

        var totalCount = await query.CountAsync();

        var users = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (users, totalCount);
    }

    public async Task AddAsync(User user)
    {
        db.Users.Add(user);
        await db.SaveChangesAsync();
    }

    public async Task UpdateAsync(User user)
    {
        db.Users.Update(user);
        await db.SaveChangesAsync();
    }
}