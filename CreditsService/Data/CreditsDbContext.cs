using CreditsService.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace CreditsService.Data;

public class CreditsDbContext(DbContextOptions<CreditsDbContext> options) : DbContext(options)
{
    public DbSet<Tariff> Tariffs => Set<Tariff>();
    public DbSet<Loan> Loans => Set<Loan>();
    public DbSet<LoanOperation> LoanOperations => Set<LoanOperation>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Tariff>(entity =>
        {
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Name).IsRequired().HasMaxLength(100);
            entity.Property(t => t.InterestRate).HasPrecision(18, 4).IsRequired();
            entity.HasIndex(t => t.IsActive);
        });

        modelBuilder.Entity<Loan>(entity =>
        {
            entity.HasKey(l => l.Id);
            entity.Property(l => l.InitialAmount).HasPrecision(18, 2).IsRequired();
            entity.Property(l => l.RemainingAmount).HasPrecision(18, 2).IsRequired();
            entity.Property(l => l.LastInterestApplicationDate).IsRequired();

            entity.HasOne(l => l.Tariff)
                .WithMany()
                .HasForeignKey(l => l.TariffId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(l => l.UserId);
            entity.HasIndex(l => l.IsActive);
            entity.HasIndex(l => l.LastInterestApplicationDate);
        });

        modelBuilder.Entity<LoanOperation>(entity =>
        {
            entity.HasKey(o => o.Id);
            entity.Property(o => o.Amount).HasPrecision(18, 2).IsRequired();

            entity.HasOne(o => o.Loan)
                .WithMany(l => l.Operations)
                .HasForeignKey(o => o.LoanId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(o => o.LoanId);
            entity.HasIndex(o => o.OperationDate);
        });
    }
}