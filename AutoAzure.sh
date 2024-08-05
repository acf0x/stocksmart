#!/bin/bash
#INSTRUCCIONES:
# 0. Establece las variables de entorno de Azure, asegurate de que no se repitan nombres de recursos
# 1. Asegrate de que estés logeado en Azure
# 2. Asegrate de que estés en el directorio raíz del proyecto
# 3. Ejecuta el script
# 4. Espera a que se cree todo los recursos


# Variables
resourceGroup="miGrupoDeRecursos3"
location="westus2"
appServicePlanFront="planFrontend3"
appServicePlanBack="planBackend3"
webAppFront="miAppFrontend3"
webAppBack="miAppBackend3"
functionApp="miFuncionApp3"
storageAccount="mistoragecuenta3"
containerName="mipubliccontainer3"
tableName="mitabla3"
keyVault="mikeyvault0000003"
cosmosDBAccount="micosmosdb00000003"
cosmosDBDatabase="mibasededatos00000003"

clear
echo "----------------------------------------------"
echo "Logeando en Azure..."
#Logear en Azure
az login
echo "Logeado en Azure"
echo "----------------------------------------------"
# Crear grupo de recursos
az group create --name $resourceGroup --location $location

# Crear plan de App Service para Frontend (.NET Core 8)
az appservice plan create --name $appServicePlanFront --resource-group $resourceGroup --sku S1 --is-linux

# Crear Web App para Frontend
az webapp create --resource-group $resourceGroup --plan $appServicePlanFront --name $webAppFront --runtime "DOTNETCORE:8.0"

# Crear plan de App Service para Backend (Python 3)
az appservice plan create --name $appServicePlanBack --resource-group $resourceGroup --sku S1 --is-linux

# Crear Web App para Backend
az webapp create --resource-group $resourceGroup --plan $appServicePlanBack --name $webAppBack --runtime "PYTHON:3.9"

# Crear Storage Account
az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_LRS

# Crear Blob Container público
az storage container create --account-name $storageAccount --name $containerName --public-access blob

# Crear Table
az storage table create --account-name $storageAccount --name $tableName

# Crear Key Vault
az keyvault create --name $keyVault --resource-group $resourceGroup --location $location

# Crear Cosmos DB cuenta
az cosmosdb create --name $cosmosDBAccount --resource-group $resourceGroup --kind GlobalDocumentDB --capabilities EnableServerless

# Crear base de datos en Cosmos DB
az cosmosdb sql database create --account-name $cosmosDBAccount --resource-group $resourceGroup --name $cosmosDBDatabase

# Crear un contenedor en Cosmos DB
az cosmosdb sql container create --account-name $cosmosDBAccount --database-name $cosmosDBDatabase --name "Products" --partition-key-path "/ProductID" --resource-group $resourceGroup

# Obtener la cadena de conexión de Cosmos DB
connectionString=$(az cosmosdb keys list --name $cosmosDBAccount --resource-group $resourceGroup --type connection-strings --query connectionStrings[0].connectionString -o tsv)

# Insertar datos de products.json a Cosmos DB usando Python
echo "Insertando datos en Cosmos DB..."
python3 << END
import json
from azure.cosmos import CosmosClient, PartitionKey

# Conectar a Cosmos DB
client = CosmosClient.from_connection_string("$connectionString")
database = client.get_database_client("$cosmosDBDatabase")
container = database.get_container_client("Products")

# Leer y insertar datos
with open('data/products.json', 'r') as file:
    products = json.load(file)
    for product in products:
        container.upsert_item(product)

print("Datos insertados con éxito en Cosmos DB.")
END

# Crear Function App (.NET Core 8, Trigger: Cosmos DB Change Document)
az functionapp create --resource-group $resourceGroup --consumption-plan-location $location --runtime dotnet-isolated --functions-version 4 --name $functionApp --storage-account $storageAccount --os-type Linux

# Configurar la Function App para usar .NET Core 8
az functionapp config set --resource-group $resourceGroup --name $functionApp --net-framework-version v8.0

# Configurar el trigger de Cosmos DB para la Function App (esto requiere configuración adicional en el código de la función)
echo "Recuerda configurar el trigger de Cosmos DB en el código de tu Function App."

echo "Recursos creados con éxito y datos insertados en Cosmos DB."