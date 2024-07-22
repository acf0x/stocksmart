from flask import Flask, jsonify, request
from azure.cosmos import CosmosClient, exceptions, PartitionKey
import uuid

app = Flask(__name__)

# Configuración de Cosmos DB
COSMOS_URL = ''
COSMOS_KEY = ''
DATABASE_NAME = ''
CONTAINER_NAME = '' 

# Inicializar el cliente de Cosmos DB
client = CosmosClient(COSMOS_URL, COSMOS_KEY)
database = client.create_database_if_not_exists(DATABASE_NAME)
container = database.create_container_if_not_exists(CONTAINER_NAME)

@app.route('/data/products', methods=['GET'])
def get_products():
    query = "SELECT * FROM c"
    items = list(container.query_items(query))
    return jsonify(items)

@app.route('/data/products/<id>', methods=['GET'])
def get_product(id):
    query = f"SELECT * FROM c WHERE c.ProductID EQUALS {id}"
    item = container.query_item(query)
    return jsonify(item)

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