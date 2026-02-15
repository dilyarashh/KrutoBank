using AccountsService.Entities;

namespace AccountsService.Data;

using Microsoft.EntityFrameworkCore;

public class AccountsDbContext(DbContextOptions<AccountsDbContext> options) : DbContext(options)
{
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<UserAccount> UserAccounts => Set<UserAccount>();
    public DbSet<AccountOperation> AccountOperations => Set<AccountOperation>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserAccount>()
            .HasKey(x => new { x.UserId, x.AccountId });

        modelBuilder.Entity<AccountOperation>()
            .HasOne(x => x.Account)
            .WithMany(x => x.Operations)
            .HasForeignKey(x => x.AccountId);
    }
}
