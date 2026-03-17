using AccountsService.Entities;
using AccountsService.Entities.Enums;
using AccountsService.Kafka.Events;
using AccountsService.Repositories;
using Confluent.Kafka;
using System.Text.Json;

namespace AccountsService.Kafka
{
    public class KafkaConsumerService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;

        public KafkaConsumerService(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var config = new ConsumerConfig
            {
                BootstrapServers = "localhost:9092",
                GroupId = "accounts-group",
                AutoOffsetReset = AutoOffsetReset.Earliest,
                EnableAutoCommit = true
            };

            using var consumer = new ConsumerBuilder<Ignore, string>(config).Build();

            consumer.Subscribe("account-operations");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var result = consumer.Consume(stoppingToken);

                    var message = JsonSerializer.Deserialize<AccountOperationEvent>(result.Message.Value);

                    if (message == null)
                    {
                        continue;
                    }

                    using var scope = _scopeFactory.CreateScope();
                    var repo = scope.ServiceProvider.GetRequiredService<IAccountRepository>();

                    var account = await repo.GetByIdAsync(message.AccountId);

                    if (account == null)
                    {
                        continue;
                    }

                    if (await repo.OperationExists(message.OperationId))
                        continue;

                    if (message.Type == "Deposit")
                    {
                        account.Balance += message.Amount;
                    }

                    if (message.Type == "Withdraw")
                    {
                        account.Balance -= message.Amount;
                    }

                    await repo.AddOperationAsync(new AccountOperation
                    {
                        Id = message.OperationId,
                        AccountId = account.Id,
                        Amount = message.Amount,
                        Type = message.Type == "Deposit"
                            ? OperationType.Deposit
                            : OperationType.Withdraw,
                        CreatedAt = DateTime.UtcNow
                    });

                    await repo.UpdateAsync(account);
                    await repo.SaveChangesAsync();
                }
                catch (ConsumeException ex)
                {
                    Console.WriteLine($"Kafka error: {ex.Error.Reason}");
                    await Task.Delay(2000);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"General error: {ex.Message}");
                }
            }
        }
    }
}
