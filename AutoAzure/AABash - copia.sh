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
functionApp="miFuncionApp0097"
storageAccount="mistoragecuenta"
containerName="mipubliccontainer"
tableName="mitabla"
keyVault="mikeyvault0097"  # Hay que cambiarlo, los nombres se quedan guardados
cosmosDBAccount="micosmosdb"
cosmosDBDatabase="mibasededatos"
cosmosDBcontainer="productos"


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

# Obtener la cadena de conexión de Cosmos DB
connectionString=$(az cosmosdb keys list --name $cosmosDBAccount --resource-group $resourceGroup --type connection-strings --query connectionStrings[0].connectionString -o tsv)

# Insertar datos de products.json a Cosmos DB usando Python

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
    with open(r'E:/dCruzCoding/stocksmart/data/products.json', 'r') as file:
        products = json.load(file)
        print("Ele ele")
        print("Datos leídos del archivo:")
        print(json.dumps(products, indent=4))

        for product in products:
            try:
                container.upsert_item(product)  # Este comando me da error
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


# Configurar el trigger de Cosmos DB para la Function App (esto requiere configuración adicional en el código de la función)
echo "Recuerda configurar el trigger de Cosmos DB en el código de tu Function App."

echo "Recursos creados con éxito y datos insertados en Cosmos DB."

# Añadir la orden "presione una tecla para continuar"
read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
echo  # Esto es para añadir una nueva línea después de presionar la tecla