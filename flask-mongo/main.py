from flask import request, url_for, jsonify
from flask_api import FlaskAPI, status, exceptions
from pymongo import MongoClient
from bson.json_util import dumps


app = FlaskAPI(__name__)

@app.route("/carts", methods=['GET'])
def list_carts():
    mongo_uri = "mongodb://mongo-router:27017"

    client = MongoClient(mongo_uri)
    db = client.shdb
    collection = db.carts

    pipeline = [
        {"$unwind":"$products"},
        {"$sortByCount":"$products.product"},
        {"$limit":5}
    ]

    cursor = collection.aggregate(pipeline)

    return jsonify(dumps(cursor))

@app.route("/users", methods=['GET'])
def list_users():
    mongo_uri = "mongodb://mongo-router:27017"

    client = MongoClient(mongo_uri)
    db = client.shdb
    collection = db.users

    pipeline = [
        {"$match":{"name":{"$regex":"^A"}}},
        {"$project":{"_id":0,"name":1,"credit":1}},
        {"$sort": {"credit":-1}},
        {"$limit":5}
    ]

    cursor = collection.aggregate(pipeline)

    return jsonify(dumps(cursor))

@app.route("/products", methods=['GET'])
def list_products():
    mongo_uri = "mongodb://mongo-router:27017"

    client = MongoClient(mongo_uri)
    db = client.shdb
    collection = db.products

    pipeline = [
        {"$match":{"company":{"$regex":"^B"}}},
        {"$project":{"_id":0,"name":1,"company":1,"price":1}},
        {"$sort":{"price":1}},
        {"$limit":2}
    ]

    cursor = collection.aggregate(pipeline)

    return jsonify(dumps(cursor))

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
