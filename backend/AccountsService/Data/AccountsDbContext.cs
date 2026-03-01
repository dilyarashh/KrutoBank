using AccountsService.Entities;
using AccountsService.Entities.Enums;
using Microsoft.EntityFrameworkCore;

namespace AccountsService.Data;

public class AccountsDbContext(DbContextOptions<AccountsDbContext> options) : DbContext(options)
{
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<UserAccount> UserAccounts => Set<UserAccount>();
    public DbSet<AccountOperation> AccountOperations => Set<AccountOperation>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserAccount>()
            .HasOne(ua => ua.Account)
            .WithMany()
            .HasForeignKey(ua => ua.AccountId);
        
        static DateTime Utc(int y, int m, int d) =>
            new DateTime(y, m, d, 0, 0, 0, DateTimeKind.Utc);

        modelBuilder.Entity<UserAccount>()
            .HasKey(x => new { x.UserId, x.AccountId });

        modelBuilder.Entity<AccountOperation>()
            .HasOne(x => x.Account)
            .WithMany(x => x.Operations)
            .HasForeignKey(x => x.AccountId);

        // GUID пользователей
        var employee1 = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var employee2 = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var client1 = Guid.Parse("33333333-3333-3333-3333-333333333333");
        var client2 = Guid.Parse("44444444-4444-4444-4444-444444444444");
        var client3 = Guid.Parse("55555555-5555-5555-5555-555555555555");

        // Счета
        var acc1 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1");
        var acc2 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2");
        var acc3 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3");
        var acc4 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4");
        var acc5 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5");
        var acc6 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6"); 

        modelBuilder.Entity<Account>().HasData(
            new Account
            {
                Id = acc1,
                Name = "Мой счёт",
                Balance = 150000,
                OpenedAt = Utc(2024, 1, 1),
                IsClosed = false
            },
            new Account
            {
                Id = acc2,
                Name = "На отдых",
                Balance = 90000,
                OpenedAt = Utc(2024, 1, 2),
                IsClosed = false
            },
            new Account
            {
                Id = acc3,
                Name = "Копилка",
                Balance = 25000,
                OpenedAt = Utc(2024, 2, 1),
                IsClosed = false
            },
            new Account
            {
                Id = acc4,
                Name = "На квартиру",
                Balance = 78000,
                OpenedAt = Utc(2024, 2, 5),
                IsClosed = false
            },
            new Account
            {
                Id = acc5,
                Name = "Просто счёт",
                Balance = 12000,
                OpenedAt = Utc(2024, 3, 1),
                IsClosed = false
            },
            new Account
            {
                Id = acc6,
                Name = "Инвестиционный",
                Balance = 50000,
                OpenedAt = Utc(2024, 3, 10),
                IsClosed = false
            }
        );

        // Связь пользователь ↔ счет
        modelBuilder.Entity<UserAccount>().HasData(
            new UserAccount { UserId = employee1, AccountId = acc1 },
            new UserAccount { UserId = employee2, AccountId = acc2 },
            new UserAccount { UserId = client1, AccountId = acc3 },
            new UserAccount { UserId = client1, AccountId = acc6 }, 
            new UserAccount { UserId = client2, AccountId = acc4 },
            new UserAccount { UserId = client3, AccountId = acc5 }
        );

        // Операции
        modelBuilder.Entity<AccountOperation>().HasData(
            new AccountOperation
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1"),
                AccountId = acc3,
                CreatedAt = Utc(2024, 2, 1),
                Type = OperationType.Deposit,
                Amount = 30000
            },
            new AccountOperation
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2"),
                AccountId = acc3,
                CreatedAt = Utc(2024, 2, 10),
                Type = OperationType.Withdraw,
                Amount = -5000
            },
            new AccountOperation
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3"),
                AccountId = acc4,
                CreatedAt = Utc(2024, 2, 5),
                Type = OperationType.Deposit,
                Amount = 80000
            },
            new AccountOperation
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4"),
                AccountId = acc5,
                CreatedAt = Utc(2024, 3, 1),
                Type = OperationType.Deposit,
                Amount = 15000
            },
            new AccountOperation
            {
                Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5"),
                AccountId = acc6,
                CreatedAt = Utc(2024, 3, 10),
                Type = OperationType.Deposit,
                Amount = 50000
            }
        );
    }
}