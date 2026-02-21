using Microsoft.EntityFrameworkCore;
using UsersService.Domain.Entities;
using UsersService.Domain.Enums;

namespace UsersService.Infrastructure.Repositories;

public class UsersDbContext(DbContextOptions<UsersDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<BlackToken> BlackTokens { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(x => x.Email)
            .IsUnique();

        var now = DateTime.UtcNow;

        modelBuilder.Entity<User>().HasData(
            //Сотрудники
            new User
            {
                Id = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                FirstName = "Ivan",
                LastName = "Petrov",
                MiddleName = "Ivanovich",
                Phone = "+79990000001",
                Email = "employee1@bank.ru",
                Birthday = new DateOnly(1990, 1, 1),
                HashPassword = "hashed_password_1",
                Role = UserRole.Employee,
                IsBlocked = false,
                Created = now
            },
            new User
            {
                Id = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                FirstName = "Anna",
                LastName = "Sidorova",
                MiddleName = "Petrovna",
                Phone = "+79990000002",
                Email = "employee2@bank.ru",
                Birthday = new DateOnly(1992, 2, 2),
                HashPassword = "hashed_password_2",
                Role = UserRole.Employee,
                IsBlocked = false,
                Created = now
            },

            //Клиенты
            new User
            {
                Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                FirstName = "Alexey",
                LastName = "Smirnov",
                MiddleName = "Sergeevich",
                Phone = "+79990000003",
                Email = "client1@bank.ru",
                Birthday = new DateOnly(1995, 3, 3),
                HashPassword = "hashed_password_3",
                Role = UserRole.Client,
                IsBlocked = false,
                Created = now
            },
            new User
            {
                Id = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                FirstName = "Maria",
                LastName = "Ivanova",
                MiddleName = "Alexandrovna",
                Phone = "+79990000004",
                Email = "client2@bank.ru",
                Birthday = new DateOnly(1998, 4, 4),
                HashPassword = "hashed_password_4",
                Role = UserRole.Client,
                IsBlocked = false,
                Created = now
            },
            new User
            {
                Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                FirstName = "Dmitry",
                LastName = "Kozlov",
                MiddleName = "Igorevich",
                Phone = "+79990000005",
                Email = "client3@bank.ru",
                Birthday = new DateOnly(2000, 5, 5),
                HashPassword = "hashed_password_5",
                Role = UserRole.Client,
                IsBlocked = false,
                Created = now
            }
        );
    }
}