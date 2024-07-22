from flask import Flask, jsonify, request
from azure.cosmos import CosmosClient, exceptions, PartitionKey

app = Flask(__name__)

# Configuración de Cosmos DB
COSMOS_URL = ''
COSMOS_KEY = ''
DATABASE_NAME = ''
CONTAINER_NAME = ''

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

@app.route('/stocks', methods=['POST'])
def create_stock():
    data = request.get_json()
    container.create_item(body=data)
    return jsonify(data), 201

if __name__ == '__main__':
    app.run(debug=True)
