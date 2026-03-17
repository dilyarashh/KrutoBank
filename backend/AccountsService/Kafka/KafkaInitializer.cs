using Confluent.Kafka;
using Confluent.Kafka.Admin;

namespace AccountsService.Kafka
{
    public class KafkaInitializer
    {
        private readonly string _bootstrapServers = "localhost:9092";

        public async Task InitializeAsync()
        {
            var config = new AdminClientConfig
            {
                BootstrapServers = _bootstrapServers
            };

            using var admin = new AdminClientBuilder(config).Build();

            try
            {
                await admin.CreateTopicsAsync(new[]
                {
                new TopicSpecification
                {
                    Name = "account-operations",
                    NumPartitions = 1,
                    ReplicationFactor = 1
                }
            });

                Console.WriteLine("Kafka topic created: account-operations");
            }
            catch (CreateTopicsException ex)
            {
                if (ex.Results.Any(r => r.Error.Code == ErrorCode.TopicAlreadyExists))
                {
                    Console.WriteLine("Kafka topic already exists");
                }
                else
                {
                    throw;
                }
            }
        }
    }
}
