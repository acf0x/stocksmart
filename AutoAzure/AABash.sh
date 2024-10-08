#!/bin/bash

# INSTRUCCIONES:
# 0. Establece las variables de entorno de Azure, asegúrate de que no se repitan nombres de recursos
# 1. Asegúrate de que estés logeado en Azure
# 2. Asegúrate de que estés en el directorio raíz del proyecto
# 3. Ejecuta el script
# 4. Espera a que se creen todos los recursos

# Variables
resourceGroup="miGrupoDeRecursos91"
location="westus2"
locationfunc="eastus"
appServicePlan="planApps91"
webAppFront="miAppFrontend91"
webAppBack="miAppBackend91"
functionApp="miFuncionApp91"
storageAccount="mistoragecuenta91"
containerName="mipubliccontainer91"
tableName="mitabla91"
keyVault="mikeyvault0091"
cosmosDBAccount="micosmosdb0091"
cosmosDBDatabase="mibasededatos0091"

clear
echo "Auto Azure MK2
░░░░░░░░░░░▄▄▀▀▀▀▀▀▀▀▄▄
░░░░░░░░▄▀▀░░░░░░░░░░░░▀▄▄
░░░░░░▄▀░░░░░░░░░░░░░░░░░░▀▄
░░░░░▌░░░░░░░░░░░░░▀▄░░░░░░░▀▀▄
░░░░▌░░░░░░░░░░░░░░░░▀▌░░░░░░░░▌
░░░▐░░░░░░░░░░░░▒░░░░░▌░░░░░░░░▐
░░░▌▐░░░░▐░░░░▐▒▒░░░░░▌░░░░░░░░░▌
░░▐░▌░░░░▌░░▐░▌▒▒▒░░░▐░░░░░▒░▌▐░▐
░░▐░▌▒░░░▌▄▄▀▀▌▌▒▒░▒░▐▀▌▀▌▄▒░▐▒▌░▌
░░░▌▌░▒░░▐▀▄▌▌▐▐▒▒▒▒▐▐▐▒▐▒▌▌░▐▒▌▄▐
░▄▀▄▐▒▒▒░▌▌▄▀▄▐░▌▌▒▐░▌▄▀▄░▐▒░▐▒▌░▀▄
▀▄▀▒▒▌▒▒▄▀░▌█▐░░▐▐▀░░░▌█▐░▀▄▐▒▌▌░░░▀
░▀▀▄▄▐▒▀▄▀░▀▄▀░░░░░░░░▀▄▀▄▀▒▌░▐
░░░░▀▐▀▄▒▀▄░░░░░░░░▐░░░░░░▀▌▐
░░░░░░▌▒▌▐▒▀░░░░░░░░░░░░░░▐▒▐
░░░░░░▐░▐▒▌░░░░��▄▀▀▀▀▄░░░░▌▒▐
░░░░░░░▌▐▒▐▄░░░▐▒▒▒▒▒▌░░▄▀▒░▐
░░░░░░▐░░▌▐▐▀▄░░▀▄▄▄▀░▄▀▐▒░░▐
░░░░░░▌▌░▌▐░▌▒▀▄▄░░░░▄▌▐░▌▒░▐
░░░░░▐▒▐░▐▐░▌▒▒▒▒▀▀▄▀▌▐░░▌▒░▌
░░░░░▌▒▒▌▐▒▌▒▒▒▒▒▒▒▒▐▀▄▌░▐▒▒▌
Made By @4k4i_"
echo "----------------------------------------------"
echo "Iniciando sesión en Azure..."
# Iniciar sesión en Azure
az login
echo "Sesión iniciada en Azure"
echo "----------------------------------------------"

# Crear grupo de recursos
az group create --name $resourceGroup --location $location

# Crear plan de App Service para Back y Front
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku S1 --is-linux

# Crear Web App para Frontend
az webapp create --resource-group $resourceGroup --plan $appServicePlan --name $webAppFront --runtime "DOTNETCORE:8.0"

# Crear Web App para Backend
az webapp create --resource-group $resourceGroup --plan $appServicePlan --name $webAppBack --runtime "PYTHON:3.9"

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
az cosmosdb sql container create --account-name $cosmosDBAccount --database-name $cosmosDBDatabase --name "Products" --partition-key-path '/ProductID' --resource-group $resourceGroup

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
az functionapp create --resource-group $resourceGroup --consumption-plan-location $locationfunc --runtime dotnet-isolated --functions-version 4 --name $functionApp --storage-account $storageAccount --os-type Linux

# Configurar la Function App para usar .NET Core 8
az functionapp config set --resource-group $resourceGroup --name $functionApp --net-framework-version v8.0

# Configurar el trigger de Cosmos DB para la Function App (esto requiere configuración adicional en el código de la función)
echo "Recuerda configurar el trigger de Cosmos DB en el código de tu Function App."

echo "Recursos creados con éxito y datos insertados en Cosmos DB."

# Añadir la orden "presione una tecla para continuar"
read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
echo  # Esto es para añadir una nueva línea después de presionar la tecla