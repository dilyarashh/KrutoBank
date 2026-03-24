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
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<UserSettings>(entity =>
            {
                entity.HasKey(x => x.UserId);

                entity.Property(x => x.Theme)
                    .HasConversion<string>();

                entity.Property(x => x.HiddenAccountIdsJson)
                    .IsRequired();
            });
        }
    }
}
