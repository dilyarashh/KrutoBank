using CreditsService.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;
using CreditsService.Entities.Enums;

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

        static DateTime Utc(int y, int m, int d) => new DateTime(y, m, d, 0, 0, 0, DateTimeKind.Utc);

        // Пользователи (как в UsersService)
        var u1 = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var u2 = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var u3 = Guid.Parse("33333333-3333-3333-3333-333333333333");
        var u4 = Guid.Parse("44444444-4444-4444-4444-444444444444");
        var u5 = Guid.Parse("55555555-5555-5555-5555-555555555555");

        // Тарифы
        var tariffStd = Guid.Parse("cccccccc-cccc-cccc-cccc-ccccccccccc1");
        var tariffFlex = Guid.Parse("cccccccc-cccc-cccc-cccc-ccccccccccc2");
        var tariffPro = Guid.Parse("cccccccc-cccc-cccc-cccc-ccccccccccc3");

        modelBuilder.Entity<Tariff>().HasData(
            new Tariff
            {
                Id = tariffStd,
                Name = "Стандарт",
                InterestRate = 0.1490m,  // 14.90%
                CreatedAt = Utc(2024, 1, 5),
                IsActive = true
            },
            new Tariff
            {
                Id = tariffFlex,
                Name = "Гибкий",
                InterestRate = 0.2190m,  // 21.90%
                CreatedAt = Utc(2024, 1, 10),
                IsActive = true
            },
            new Tariff
            {
                Id = tariffPro,
                Name = "Премиум",
                InterestRate = 0.0990m,  // 9.90%
                CreatedAt = Utc(2024, 1, 15),
                IsActive = true
            }
        );

        // Кредиты (2-3 на каждого пользователя, разные тарифы)
        // u1 (2 кредита)
        var l1 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd1");
        var l2 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd2");

        // u2 (2 кредита)
        var l3 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd3");
        var l4 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd4");

        // u3 (3 кредита)
        var l5 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd5");
        var l6 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd6");
        var l7 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd7");

        // u4 (3 кредита)
        var l8 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd8");
        var l9 = Guid.Parse("dddddddd-dddd-dddd-dddd-ddddddddddd9");
        var l10 = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddd10");

        // u5 (3 кредита)
        var l11 = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddd11");
        var l12 = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddd12");
        var l13 = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddd13");

        modelBuilder.Entity<Loan>().HasData(
            // u1
            new Loan
            {
                Id = l1,
                UserId = u1,
                TariffId = tariffStd,
                InitialAmount = 120000m,
                RemainingAmount = 90000m, // будет частичное погашение 30k
                CreatedAt = Utc(2024, 2, 1),
                LastInterestApplicationDate = Utc(2024, 2, 1),
                IsActive = true
            },
            new Loan
            {
                Id = l2,
                UserId = u1,
                TariffId = tariffPro,
                InitialAmount = 300000m,
                RemainingAmount = 240000m, // погашение 60k
                CreatedAt = Utc(2024, 3, 5),
                LastInterestApplicationDate = Utc(2024, 3, 5),
                IsActive = true
            },

            // u2
            new Loan
            {
                Id = l3,
                UserId = u2,
                TariffId = tariffFlex,
                InitialAmount = 80000m,
                RemainingAmount = 65000m, // погашение 15k
                CreatedAt = Utc(2024, 2, 10),
                LastInterestApplicationDate = Utc(2024, 2, 10),
                IsActive = true
            },
            new Loan
            {
                Id = l4,
                UserId = u2,
                TariffId = tariffStd,
                InitialAmount = 200000m,
                RemainingAmount = 175000m, // погашение 25k
                CreatedAt = Utc(2024, 4, 1),
                LastInterestApplicationDate = Utc(2024, 4, 1),
                IsActive = true
            },

            // u3
            new Loan
            {
                Id = l5,
                UserId = u3,
                TariffId = tariffPro,
                InitialAmount = 150000m,
                RemainingAmount = 110000m, // погашение 40k
                CreatedAt = Utc(2024, 1, 20),
                LastInterestApplicationDate = Utc(2024, 1, 20),
                IsActive = true
            },
            new Loan
            {
                Id = l6,
                UserId = u3,
                TariffId = tariffStd,
                InitialAmount = 50000m,
                RemainingAmount = 38000m, // погашение 12k
                CreatedAt = Utc(2024, 2, 25),
                LastInterestApplicationDate = Utc(2024, 2, 25),
                IsActive = true
            },
            new Loan
            {
                Id = l7,
                UserId = u3,
                TariffId = tariffFlex,
                InitialAmount = 90000m,
                RemainingAmount = 72000m, // погашение 18k
                CreatedAt = Utc(2024, 5, 10),
                LastInterestApplicationDate = Utc(2024, 5, 10),
                IsActive = true
            },

            // u4
            new Loan
            {
                Id = l8,
                UserId = u4,
                TariffId = tariffStd,
                InitialAmount = 60000m,
                RemainingAmount = 45000m, // погашение 15k
                CreatedAt = Utc(2024, 3, 12),
                LastInterestApplicationDate = Utc(2024, 3, 12),
                IsActive = true
            },
            new Loan
            {
                Id = l9,
                UserId = u4,
                TariffId = tariffPro,
                InitialAmount = 400000m,
                RemainingAmount = 340000m, // погашение 60k
                CreatedAt = Utc(2024, 6, 1),
                LastInterestApplicationDate = Utc(2024, 6, 1),
                IsActive = true
            },
            new Loan
            {
                Id = l10,
                UserId = u4,
                TariffId = tariffFlex,
                InitialAmount = 100000m,
                RemainingAmount = 85000m, // погашение 15k
                CreatedAt = Utc(2024, 7, 7),
                LastInterestApplicationDate = Utc(2024, 7, 7),
                IsActive = true
            },

            // u5
            new Loan
            {
                Id = l11,
                UserId = u5,
                TariffId = tariffPro,
                InitialAmount = 220000m,
                RemainingAmount = 190000m, // погашение 30k
                CreatedAt = Utc(2024, 2, 2),
                LastInterestApplicationDate = Utc(2024, 2, 2),
                IsActive = true
            },
            new Loan
            {
                Id = l12,
                UserId = u5,
                TariffId = tariffStd,
                InitialAmount = 70000m,
                RemainingAmount = 52000m, // погашение 18k
                CreatedAt = Utc(2024, 4, 20),
                LastInterestApplicationDate = Utc(2024, 4, 20),
                IsActive = true
            },
            new Loan
            {
                Id = l13,
                UserId = u5,
                TariffId = tariffFlex,
                InitialAmount = 130000m,
                RemainingAmount = 100000m, // погашение 30k
                CreatedAt = Utc(2024, 8, 15),
                LastInterestApplicationDate = Utc(2024, 8, 15),
                IsActive = true
            }
        );

        modelBuilder.Entity<LoanOperation>().HasData(
            // l1: 30k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1"),
                LoanId = l1,
                Amount = 10000m,
                OperationDate = Utc(2024, 2, 15),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2"),
                LoanId = l1,
                Amount = 20000m,
                OperationDate = Utc(2024, 3, 1),
                Type = LoanOperationType.Repayment
            },

            // l2: 60k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3"),
                LoanId = l2,
                Amount = 25000m,
                OperationDate = Utc(2024, 3, 20),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4"),
                LoanId = l2,
                Amount = 35000m,
                OperationDate = Utc(2024, 4, 10),
                Type = LoanOperationType.Repayment
            },

            // l3: 15k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5"),
                LoanId = l3,
                Amount = 15000m,
                OperationDate = Utc(2024, 3, 3),
                Type = LoanOperationType.Repayment
            },

            // l4: 25k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee6"),
                LoanId = l4,
                Amount = 10000m,
                OperationDate = Utc(2024, 4, 15),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee7"),
                LoanId = l4,
                Amount = 15000m,
                OperationDate = Utc(2024, 5, 5),
                Type = LoanOperationType.Repayment
            },

            // l5: 40k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee8"),
                LoanId = l5,
                Amount = 20000m,
                OperationDate = Utc(2024, 2, 10),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee9"),
                LoanId = l5,
                Amount = 20000m,
                OperationDate = Utc(2024, 3, 10),
                Type = LoanOperationType.Repayment
            },

            // l6: 12k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee10"),
                LoanId = l6,
                Amount = 12000m,
                OperationDate = Utc(2024, 3, 1),
                Type = LoanOperationType.Repayment
            },

            // l7: 18k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee11"),
                LoanId = l7,
                Amount = 8000m,
                OperationDate = Utc(2024, 5, 25),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee12"),
                LoanId = l7,
                Amount = 10000m,
                OperationDate = Utc(2024, 6, 10),
                Type = LoanOperationType.Repayment
            },

            // l8: 15k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee13"),
                LoanId = l8,
                Amount = 15000m,
                OperationDate = Utc(2024, 4, 1),
                Type = LoanOperationType.Repayment
            },

            // l9: 60k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee14"),
                LoanId = l9,
                Amount = 30000m,
                OperationDate = Utc(2024, 6, 20),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee15"),
                LoanId = l9,
                Amount = 30000m,
                OperationDate = Utc(2024, 7, 20),
                Type = LoanOperationType.Repayment
            },

            // l10: 15k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee16"),
                LoanId = l10,
                Amount = 15000m,
                OperationDate = Utc(2024, 8, 1),
                Type = LoanOperationType.Repayment
            },

            // l11: 30k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee17"),
                LoanId = l11,
                Amount = 10000m,
                OperationDate = Utc(2024, 2, 20),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee18"),
                LoanId = l11,
                Amount = 20000m,
                OperationDate = Utc(2024, 3, 20),
                Type = LoanOperationType.Repayment
            },

            // l12: 18k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee19"),
                LoanId = l12,
                Amount = 8000m,
                OperationDate = Utc(2024, 5, 1),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee20"),
                LoanId = l12,
                Amount = 10000m,
                OperationDate = Utc(2024, 5, 25),
                Type = LoanOperationType.Repayment
            },

            // l13: 30k
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee21"),
                LoanId = l13,
                Amount = 15000m,
                OperationDate = Utc(2024, 9, 1),
                Type = LoanOperationType.Repayment
            },
            new LoanOperation
            {
                Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeee22"),
                LoanId = l13,
                Amount = 15000m,
                OperationDate = Utc(2024, 10, 1),
                Type = LoanOperationType.Repayment
            }
        );
    }
}