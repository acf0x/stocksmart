from flask import Flask, jsonify, request
from dotenv import load_dotenv
from azure.cosmos import CosmosClient, exceptions
import os
import uuid


app = Flask(__name__)
load_dotenv()

# Configuración de Cosmos DB 
# TODO: PONERLO BONITO -> incluir archivo configuración-userfriendly
cosmos_url = os.getenv("url")
cosmos_key = os.getenv("key")
database_name = os.getenv("db")
container_name = os.getenv("container")

# Inicializar el cliente de Cosmos DB
client = CosmosClient(cosmos_url, cosmos_key)
database = client.get_database_client(database_name)
container = database.get_container_client(container_name)


# GET products
@app.route('/productos', methods=['GET'])
def get_products():
    query = "SELECT * FROM c"
    
    try:
        items = list(container.query_items(query, enable_cross_partition_query=True))
        if not items:
            return jsonify({"message": "No se encontraron productos."}), 404
        return jsonify(items)
    
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500


# GET products/id
@app.route('/productos/<id>', methods=['GET'])
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


# POST product
@app.route('/productos', methods=['POST'])
def create_product():
    product_data = request.json
    if not product_data:
        return jsonify({"message": "Datos del producto no proporcionados."}), 400
    
    try:
        # Asignar un id único
        product_data['id'] = str(uuid.uuid4())

        # Obtener el ProductID más alto 
        query = "SELECT VALUE c.ProductID FROM c"
        items = list(container.query_items(query, enable_cross_partition_query=True))

        # Filtrar y convertir a enteros solo si es posible
        product_ids = [int(item) for item in items if item.isdigit()]

        # Verifica si la lista no está vacía
        if product_ids:
            # Obtener el valor máximo de ProductID
            max_id_item = max(product_ids)
            new_product_id = max_id_item + 1
        else:
            # Si no hay productos en la base de datos, comienza desde 1
            new_product_id = 1

        # Asignar el nuevo ProductID como cadena
        product_data['ProductID'] = str(new_product_id)
        product_data['productID'] = product_data['ProductID']

        # Crear el nuevo producto en la base de datos
        container.create_item(body=product_data)

        # Devolver una respuesta exitosa
        return jsonify({"message": "Producto creado exitosamente.", "Product_id": product_data['ProductID']}), 201
    
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500


# PUT product
@app.route('/productos/<id>', methods=['PUT'])
def update_product(id):
    product_data = request.json
    if not product_data:
        return jsonify({"message": "Datos del producto no proporcionados."}), 400

    query = f"SELECT * FROM c WHERE c.ProductID = '{id}'"
    
    try:
        items = container.query_items(query)
        item = next(items, None)  # Obtener el primer ítem o None si no hay resultados
        if item is None:
            return jsonify({"message": "Producto no encontrado."}), 404
        
        # Actualizar el documento con los datos proporcionados
        for key, value in product_data.items():
            item[key] = value
        
        # Reemplazar el documento en la base de datos
        container.replace_item(item=item, body=item)
        return jsonify({"message": "Producto actualizado correctamente."}), 200
    
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500


# DELETE product
@app.route('/productos/<id>', methods=['DELETE'])
def delete_product(id):
    try:
        container.delete_item(item=id, partition_key="/ProductID")
        return jsonify({"message": "Producto eliminado correctamente."}), 200
    
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({"Error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)