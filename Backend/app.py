from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
from bson import ObjectId
from dotenv import load_dotenv
import os
import datetime

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# MongoDB Configuration
app.config["MONGO_URI"] = os.getenv("MONGODB_URI") + os.getenv("DATABASE_NAME")
mongo = PyMongo(app)

# Helper function to convert ObjectId to string
def parse_json(data):
    if isinstance(data, list):
        return [parse_json(item) for item in data]
    elif isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, ObjectId):
                data[key] = str(value)
            elif isinstance(value, (dict, list)):
                data[key] = parse_json(value)
        return data
    return data

@app.route("/news", methods=["GET"])
def get_news():
    # TODO before calling this, we need to have stored some news fetched from the API into our mongodb database
    # Get query parameters
    positivity = request.args.get("positivity", type=float)
    interest = request.args.get("interest")
    
    # Build query
    query = {}
    if positivity is not None:
        query["positivity_percentage"] = {"$gte": positivity}
    if interest:
        query["interest"] = interest
    
    # Fetch news articles
    news = list(mongo.db.news.find(query))
    return jsonify(parse_json(news))

@app.route("/news/<id>", methods=["GET"])
def get_news_detail(id):
    # TODO same as previous one
    try:
        # Find news article and its comments
        news = mongo.db.news.find_one({"_id": ObjectId(id)})
        if not news:
            return jsonify({"error": "News article not found"}), 404
            
        comments = list(mongo.db.comments.find({"news_id": ObjectId(id)}))
        news["comments"] = comments
        
        return jsonify(parse_json(news))
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/news/<id>/comments", methods=["GET"])
def get_comments(id):
    try:
        comments = list(mongo.db.comments.find({"news_id": ObjectId(id)}))
        return jsonify(parse_json(comments))
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/news/<id>/comments", methods=["POST"])
def add_comment(id):
    try:
        # Validate request data
        data = request.get_json()
        if not data or "content" not in data:
            return jsonify({"error": "Comment content is required"}), 400
            
        # Create comment
        comment = {
            "news_id": ObjectId(id),
            "content": data["content"],
            "created_at": datetime.datetime.utcnow()
        }
        
        result = mongo.db.comments.insert_one(comment)
        comment["_id"] = str(result.inserted_id)
        
        return jsonify(comment), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True) 