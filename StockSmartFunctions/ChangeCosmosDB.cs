using System;
using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Cosmos.Table;

namespace StockSmartFunctions
{
    public class ChangeCosmosDB
    {
        private readonly ILogger _logger;
        private readonly CloudTable _logTable;

        public ChangeCosmosDB(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ChangeCosmosDB>();
            // Inicializa la tabla de logs
            var storageAccount = CloudStorageAccount.Parse("cuentaStorage");
            var tableClient = storageAccount.CreateCloudTableClient();
            _logTable = tableClient.GetTableReference("CosmosDB-Logs");
            _logTable.CreateIfNotExists(); // Crea la tabla si no existe
        }

        [Function("ChangeCosmosDB")]
        public void Run([CosmosDBTrigger(
            databaseName: "mibasededatos",
            containerName: "productos",
            Connection = "DBconnectionstring",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<ProductInfo> input)
        {
            if (input != null && input.Count > 0)
            {
                _logger.LogInformation("Documents modified: " + input.Count);
                LogUpdates(input); // Llama al método para registrar las actualizaciones
            }
        }

        private void LogUpdates(IReadOnlyList<ProductInfo> input)
        {
            foreach (var item in input)
            {
                var logEntity = new DynamicTableEntity("UpdateLog", Guid.NewGuid().ToString())
                {
                    Properties = {
                        { "ProductID", new EntityProperty(item.ProductID) },
                        { "ProductName", new EntityProperty(item.ProductName) },
                        { "Timestamp", new EntityProperty(DateTime.UtcNow) }
                    }
                };
                var insertOperation = TableOperation.Insert(logEntity);
                try
                {
                    _logTable.Execute(insertOperation); // Ejecuta la operación de inserción
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error al insertar el log: {ex.Message}");
                }
            }
        }
    }

    public class ProductInfo
    {
        public string ProductID { get; set; }
        public string ProductName { get; set; }
    }
}
