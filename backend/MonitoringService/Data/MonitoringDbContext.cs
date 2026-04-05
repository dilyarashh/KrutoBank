using Microsoft.EntityFrameworkCore;
using MonitoringService.Entities;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace MonitoringService.Data
{
    public class MonitoringDbContext : DbContext
    {
        public MonitoringDbContext(DbContextOptions<MonitoringDbContext> options) : base(options)
        {
        }

        public DbSet<RequestLog> RequestLogs => Set<RequestLog>();
        public DbSet<ExceptionLog> ExceptionLogs => Set<ExceptionLog>();
        public DbSet<TraceSpan> TraceSpans => Set<TraceSpan>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<RequestLog>(entity =>
            {
                entity.HasKey(x => x.Id);
                entity.Property(x => x.ServiceName).IsRequired();
                entity.Property(x => x.Method).IsRequired();
                entity.Property(x => x.Path).IsRequired();
                entity.Property(x => x.TraceId).IsRequired();
                entity.Property(x => x.SpanId).IsRequired();
            });

            modelBuilder.Entity<ExceptionLog>(entity =>
            {
                entity.HasKey(x => x.Id);
                entity.Property(x => x.ServiceName).IsRequired();
                entity.Property(x => x.Method).IsRequired();
                entity.Property(x => x.Path).IsRequired();
                entity.Property(x => x.TraceId).IsRequired();
                entity.Property(x => x.SpanId).IsRequired();
                entity.Property(x => x.Message).IsRequired();
            });

            modelBuilder.Entity<TraceSpan>(entity =>
            {
                entity.HasKey(x => x.Id);
                entity.Property(x => x.ServiceName).IsRequired();
                entity.Property(x => x.TraceId).IsRequired();
                entity.Property(x => x.SpanId).IsRequired();
                entity.Property(x => x.OperationName).IsRequired();
                entity.Property(x => x.Status).IsRequired();
            });
        }
    }
}
