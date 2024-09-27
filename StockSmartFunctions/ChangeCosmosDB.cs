using System;
using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using DotNetEnv;

namespace StockSmartFunctions
{
    public class ChangeCosmosDB
    {
        private readonly ILogger _logger;

        public ChangeCosmosDB(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ChangeCosmosDB>();

            Env.Load();
        }

        [Function("ChangeCosmosDB")]
        public void Run([CosmosDBTrigger(
            databaseName: Environment.GetEnvironmentVariable("db"),
            containerName: Environment.GetEnvironmentVariable("container"),
            Connection = Environment.GetEnvironmentVariable("connectionstring"),
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<MyInfo> input)
        {
            if (input != null && input.Count > 0)
            {
                _logger.LogInformation("Documents modified: " + input.Count);
                _logger.LogInformation("First document Id: " + input[0].id);
            }
        }
    }

    public class MyInfo
    {
        public string id { get; set; }
        public string Text { get; set; }
        public int Number { get; set; }
        public bool Boolean { get; set; }
    }
}
