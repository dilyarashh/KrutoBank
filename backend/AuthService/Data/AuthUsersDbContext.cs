using AuthService.Entities;
using Microsoft.EntityFrameworkCore;

namespace AuthService.Data;

public class AuthUsersDbContext(DbContextOptions<AuthUsersDbContext> options) : DbContext(options)
{
    public DbSet<AuthUser> Users => Set<AuthUser>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<AuthUser>(entity =>
        {
            entity.ToTable("Users");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FirstName).HasMaxLength(128).IsRequired();
            entity.Property(x => x.LastName).HasMaxLength(128).IsRequired();
            entity.Property(x => x.MiddleName).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Phone).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.Birthday).IsRequired();
            entity.Property(x => x.HashPassword).IsRequired();
            entity.Property(x => x.Role).IsRequired();
            entity.Property(x => x.IsBlocked).IsRequired();
            entity.Property(x => x.Created).IsRequired();
            entity.HasIndex(x => x.Email).IsUnique();
        });
    }
}
