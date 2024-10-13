#!/bin/bash

# INSTRUCCIONES:
# 0. Establece las variables de entorno de Azure, asegúrate de que no se repitan nombres de recursos
# 1. Asegúrate de que estés logeado en Azure
# 2. Asegúrate de que estés en el directorio raíz del proyecto
# 3. Ejecuta el script
# 4. Espera a que se creen todos los recursos

# Variables
resourceGroup="miGrupoDeRecursos"
location="westus2"
locationfunc="eastus"
appServicePlan="planApps"
webAppFront="miAppFrontend"
webAppBack="miAppBackend"
functionApp="miFuncionApp0098"
storageAccount="mistoragecuenta"
containerName="mipubliccontainer"
tableName="mitabla"
keyVault="mikeyvault0098"  # Hay que cambiarlo, los nombres se quedan guardados
cosmosDBAccount="micosmosdb"
cosmosDBDatabase="mibasededatos"
cosmosDBcontainer="productos"

clear

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
echo "Creando contenedor en Cosmos DB..."
az cosmosdb sql container create \
  --resource-group "$resourceGroup" \
  --account-name "$cosmosDBAccount" \
  --database-name "$cosmosDBDatabase" \
  --name "$cosmosDBcontainer" \
  --partition-key-path "//ProductID"

if [ $? -eq 0 ]; then
    echo "Contenedor '$cosmosDBcontainer' creado exitosamente en la base de datos '$cosmosDBDatabase'."
else
    echo "Error al crear el contenedor. Verifique la información e inténtelo de nuevo."
fi

# Obtener la cadena de conexión de Cosmos DB
connectionString=$(az cosmosdb keys list --name $cosmosDBAccount --resource-group $resourceGroup --type connection-strings --query connectionStrings[0].connectionString -o tsv)

# Insertar datos de products.json a Cosmos DB usando Python
echo "Insertando datos en Cosmos DB..."
python << END
import json
from azure.cosmos import CosmosClient, PartitionKey, exceptions

# Definir las variables dentro del bloque de Python
connection_string = "$connectionString"
database_name = "$cosmosDBDatabase"
container_name = "$cosmosDBcontainer"

# Conectar a Cosmos DB
client = CosmosClient.from_connection_string(connection_string)
database = client.get_database_client(database_name)
container = database.get_container_client(container_name)
print(f"Conexión a cuenta CosmosDB '{database_name}' realizada")


# Leer y insertar datos
try:
    with open(r'C:/products.json', 'r') as file:
        products = json.load(file)
        print("Ele ele")
        print("Datos leídos del archivo:")
        print(json.dumps(products, indent=4))
        
        for product in products:
            try:
                product['ProductID'] = str(product['ProductID'])
                container.upsert_item(product)   # Este comando me da error
                # El error que estás encontrando al intentar insertar 
                        #   indica que uno de los campos proporcionados no es válido.
                print(f"Producto insertado: {product}") 
            except exceptions.CosmosHttpResponseError as e:
                print(f"Error al insertar el producto {product}: {e.message}")

    print("Datos insertados con éxito en Cosmos DB.")
except FileNotFoundError:
    print("Error: El archivo no se encuentra en la ruta especificada.")
except json.JSONDecodeError:
    print("Error: El archivo no se pudo decodificar como JSON. Verifica el formato del archivo.")
except Exception as e:
    print(f"Ocurrió un error inesperado: {e}")
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