from flask import Flask, jsonify, request
from azure.cosmos import CosmosClient, exceptions, PartitionKey
import uuid

app = Flask(__name__)

# Configuración de Cosmos DB
COSMOS_URL = 'https://democosmospd.documents.azure.com/'
COSMOS_KEY = '0xeX5OLpoabjFyt21r1k0sPgh7ITL84wUMNSpqoC7u8dnwQNgb5XlxMqlRIuKlXphvtlKEhQ57V3ACDb4dyRNw=='
DATABASE_NAME = 'democosmospd'
CONTAINER_NAME = 'democontainerpd'

# Inicializar el cliente de Cosmos DB
client = CosmosClient(COSMOS_URL, COSMOS_KEY)
database = client.create_database_if_not_exists(id=DATABASE_NAME)
container = database.create_container_if_not_exists(
    id=CONTAINER_NAME,
    partition_key=PartitionKey(path="/id")
)

@app.route('/data/products', methods=['GET'])
def get_stocks():
    query = "SELECT * FROM c"
    items = list(container.query_items(
        query=query,
        enable_cross_partition_query=True
    ))
    return jsonify(items)

@app.route('/productos/nuevo', methods=['POST'])
def create_stock():
    data = request.get_json()
    
    # Validar y extraer los parámetros
    descripcion = data.get('descripcion')
    proveedor = data.get('proveedor')
    categoria = data.get('categoria')
    cantidades_por_unidad = data.get('cantidades_por_unidad')
    precio = data.get('precio')
    stock = data.get('stock')
    stock_pedido = data.get('stock_pedido')
    nivel = data.get('nivel')
    descuentos = data.get('descuentos')

    # Crear el nuevo ítem con los parámetros
    nuevo_item = {
        'id': str(uuid.uuid4()),  # Generar un ID único
        'descripcion': descripcion,
        'proveedor': proveedor,
        'categoria': categoria,
        'cantidades_por_unidad': cantidades_por_unidad,
        'precio': precio,
        'stock': stock,
        'stock_pedido': stock_pedido,
        'nivel': nivel,
        'descuentos': descuentos
    }

    # Insertar el nuevo ítem en el contenedor
    container.create_item(body=nuevo_item)
    return jsonify(nuevo_item), 201

if __name__ == '__main__':
    app.run(debug=True)