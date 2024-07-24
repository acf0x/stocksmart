from flask import Flask, jsonify, request
from azure.cosmos import CosmosClient, exceptions, PartitionKey
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import uuid

app = Flask(__name__)

# Configuración de Cosmos DB
COSMOS_URL = "https://cosmosdbpd.documents.azure.com/"
KEY_VAULT_URL = "https://demokeyvaultpd2.vault.azure.net/"
SECRET_NAME = "cosmoskey"

# Obtener la clave de Cosmos DB desde Azure Key Vault
credential = DefaultAzureCredential()
secret_client = SecretClient(KEY_VAULT_URL, credential)
COSMOS_KEY = secret_client.get_secret(SECRET_NAME).value

DATABASE_NAME = "stockdb"
CONTAINER_NAME = "products"
# Inicializar el cliente de Cosmos DB
client = CosmosClient(COSMOS_URL, COSMOS_KEY)
database = client.create_database_if_not_exists(DATABASE_NAME)
container = database.create_container_if_not_exists(CONTAINER_NAME, PartitionKey('/ProductID'))

@app.route('/data/products', methods=['GET'])
def get_products():
    query = "SELECT * FROM c"
    try:
        items = list(container.query_items(query, enable_cross_partition_query=True))
        if not items:
            return jsonify({"message": "No se encontraron productos."}), 404
        return jsonify(items)
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500

@app.route('/data/products/<id>', methods=['GET'])
def get_product(id):
    query = f"SELECT * FROM c WHERE c.ProductID = '{id}'"
    try:
        items = container.query_items(query)
        item = next(items, None)  # Obtener el primer ítem o None si no hay resultados
        if item is None:
            return jsonify({"message": "Producto no encontrado."}), 404
        return jsonify(item)
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500

@app.route('/products/new', methods=['POST'])
def create_product():
    data = request.get_json()

    # Validar y extraer los parámetros
    #nombre = data.get('ProductName')
    #proveedorID = data.get('SupplierID')
    #categoriaID = data.get('CategoryID')
    #cantidadesPorUnidad = data.get('QuantityPerUnit')
    #precioUnidad = data.get('UnitPrice')
    #stock = data.get('UnitsInStock')
    #stockReservado = data.get('UnitsOnOrder')
    #reorderLevel = data.get('ReorderLevel')
    #descontinuado = data.get('Discontinued')

    # Crear el nuevo ítem con los parámetros
    nuevo_item = {
        'ProductID': str(uuid.uuid4()),  # Generar un ID único
        'ProductName': data.get('ProductName'),
        'SupplierID': data.get('SupplierID'),
        'CategoryID': data.get('CategoryID'),
        'QuantityPerUnit': data.get('QuantityPerUnit'),
        'UnitPrice': data.get('UnitPrice'),
        'UnitsInStock': data.get('UnitsInStock'),
        'UnitsOnOrder': data.get('UnitsOnOrder'),
        'ReorderLevel': data.get('ReorderLevel'),
        'Discontinued': data.get('Discontinued')
    }

    # Insertar el nuevo ítem en el contenedor
    container.create_item(nuevo_item)
    return jsonify(nuevo_item), 201

if __name__ == '__main__':
    app.run(debug=True)