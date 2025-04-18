from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson import ObjectId
from dotenv import load_dotenv
import os
import datetime

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# MongoDB Configuration
mongodb_uri = os.getenv("MONGODB_URI", "mongodb://localhost:27017/")
database_name = os.getenv("DATABASE_NAME", "zenframe")

# Create MongoDB client
client = MongoClient(mongodb_uri)
app.db = client[database_name]

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
            elif isinstance(value, datetime.datetime):
                data[key] = value.isoformat()
        return data
    return data

@app.route("/news", methods=["GET"])
def get_news():
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
    news = list(app.db.news.find(query))
    return jsonify(parse_json(news))

@app.route("/news/<id>", methods=["GET"])
def get_news_detail(id):
    try:
        # Find news article and its comments
        news = app.db.news.find_one({"_id": ObjectId(id)})
        if not news:
            return jsonify({"error": "News article not found"}), 404
            
        comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
        news["comments"] = comments
        
        return jsonify(parse_json(news))
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/news/<id>/comments", methods=["GET"])
def get_comments(id):
    try:
        comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
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
        
        result = app.db.comments.insert_one(comment)
        comment["_id"] = str(result.inserted_id)
        
        return jsonify(parse_json(comment)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True) 