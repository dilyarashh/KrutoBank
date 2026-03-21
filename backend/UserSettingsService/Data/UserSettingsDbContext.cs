using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;
using UserSettingsService.Entities;

namespace UserSettingsService.Data
{
    public class UserSettingsDbContext(DbContextOptions<UserSettingsDbContext> options) : DbContext(options)
    {
        public DbSet<UserSettings> UserSettings => Set<UserSettings>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserSettings>()
                .HasKey(x => x.UserId);
        }
    }
}
