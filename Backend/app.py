# # from flask import Flask, request, jsonify
# # from flask_cors import CORS
# # from pymongo import MongoClient
# # from bson import ObjectId
# # from dotenv import load_dotenv
# # import os
# # import datetime

# # # Load environment variables
# # load_dotenv()

# # app = Flask(__name__)
# # CORS(app)  # Enable CORS for all routes

# # # MongoDB Configuration
# # mongodb_uri = os.getenv("MONGODB_URI", "mongodb://localhost:27017/")
# # database_name = os.getenv("DATABASE_NAME", "zenframe")

# # # Create MongoDB client
# # client = MongoClient(mongodb_uri)
# # app.db = client[database_name]

# # # Helper function to convert ObjectId to string
# # def parse_json(data):
# #     if isinstance(data, list):
# #         return [parse_json(item) for item in data]
# #     elif isinstance(data, dict):
# #         for key, value in data.items():
# #             if isinstance(value, ObjectId):
# #                 data[key] = str(value)
# #             elif isinstance(value, (dict, list)):
# #                 data[key] = parse_json(value)
# #             elif isinstance(value, datetime.datetime):
# #                 data[key] = value.isoformat()
# #         return data
# #     return data

# # @app.route("/news", methods=["GET"])
# # def get_news():
# #     # Get query parameters
# #     positivity = request.args.get("positivity", type=float)
# #     interest = request.args.get("interest")
    
# #     # Build query
# #     query = {}
# #     if positivity is not None:
# #         query["positivity_percentage"] = {"$gte": positivity}
# #     if interest:
# #         query["interest"] = interest
    
# #     # Fetch news articles
# #     news = list(app.db.news.find(query))
# #     return jsonify(parse_json(news))

# # @app.route("/news/<id>", methods=["GET"])
# # def get_news_detail(id):
# #     try:
# #         # Find news article and its comments
# #         news = app.db.news.find_one({"_id": ObjectId(id)})
# #         if not news:
# #             return jsonify({"error": "News article not found"}), 404
            
# #         comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
# #         news["comments"] = comments
        
# #         return jsonify(parse_json(news))
# #     except Exception as e:
# #         return jsonify({"error": str(e)}), 400

# # @app.route("/news/<id>/comments", methods=["GET"])
# # def get_comments(id):
# #     try:
# #         comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
# #         return jsonify(parse_json(comments))
# #     except Exception as e:
# #         return jsonify({"error": str(e)}), 400

# # @app.route("/news/<id>/comments", methods=["POST"])
# # def add_comment(id):
# #     try:
# #         # Validate request data
# #         data = request.get_json()
# #         if not data or "content" not in data:
# #             return jsonify({"error": "Comment content is required"}), 400
            
# #         # Create comment
# #         comment = {
# #             "news_id": ObjectId(id),
# #             "content": data["content"],
# #             "created_at": datetime.datetime.utcnow()
# #         }
        
# #         result = app.db.comments.insert_one(comment)
# #         comment["_id"] = str(result.inserted_id)
        
# #         return jsonify(parse_json(comment)), 201
# #     except Exception as e:
# #         return jsonify({"error": str(e)}), 400

# # if __name__ == "__main__":
# #     app.run(debug=True) 

# from flask import Flask, request, jsonify
# from flask_cors import CORS
# from pymongo import MongoClient
# from bson import ObjectId
# from dotenv import load_dotenv
# import os
# import datetime

# # Load environment variables
# load_dotenv()

# # Flask app setup
# app = Flask(__name__)
# CORS(app)

# # MongoDB setup
# mongodb_uri = os.getenv("MONGODB_URI", "mongodb://localhost:27017/")
# database_name = os.getenv("DATABASE_NAME", "zenframe")
# client = MongoClient(mongodb_uri)
# app.db = client[database_name]

# # Helper to parse Mongo ObjectId and datetime
# def parse_json(data):
#     if isinstance(data, list):
#         return [parse_json(item) for item in data]
#     elif isinstance(data, dict):
#         for key, value in data.items():
#             if isinstance(value, ObjectId):
#                 data[key] = str(value)
#             elif isinstance(value, (dict, list)):
#                 data[key] = parse_json(value)
#             elif isinstance(value, datetime.datetime):
#                 data[key] = value.isoformat()
#         return data
#     return data

# # ================= Helper Functions =================

# def add_news_to_database(original_title, rewritten_title, summary, positivity_percentage=100, interest="General"):
#     """Function to insert a rewritten news article into MongoDB"""
#     news_article = {
#         "original_title": original_title,
#         "rewritten_title": rewritten_title,
#         "summary": summary,
#         "positivity_percentage": positivity_percentage,
#         "interest": interest,
#         "created_at": datetime.datetime.utcnow()
#     }
#     result = app.db.news.insert_one(news_article)
#     news_article["_id"] = str(result.inserted_id)
#     return news_article

# def add_comment_to_database(news_id, content):
#     """Function to insert a comment related to a news article into MongoDB"""
#     comment = {
#         "news_id": ObjectId(news_id),
#         "content": content,
#         "created_at": datetime.datetime.utcnow()
#     }
#     result = app.db.comments.insert_one(comment)
#     comment["_id"] = str(result.inserted_id)
#     return comment

# # =================== Routes ===================

# @app.route("/news", methods=["GET"])
# def get_news():
#     positivity = request.args.get("positivity", type=float)
#     interest = request.args.get("interest")

#     query = {}
#     if positivity is not None:
#         query["positivity_percentage"] = {"$gte": positivity}
#     if interest:
#         query["interest"] = interest

#     news = list(app.db.news.find(query))
#     return jsonify(parse_json(news))

# @app.route("/news/<id>", methods=["GET"])
# def get_news_detail(id):
#     try:
#         news = app.db.news.find_one({"_id": ObjectId(id)})
#         if not news:
#             return jsonify({"error": "News article not found"}), 404

#         comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
#         news["comments"] = comments

#         return jsonify(parse_json(news))
#     except Exception as e:
#         return jsonify({"error": str(e)}), 400

# @app.route("/news/<id>/comments", methods=["GET"])
# def get_comments(id):
#     try:
#         comments = list(app.db.comments.find({"news_id": ObjectId(id)}))
#         return jsonify(parse_json(comments))
#     except Exception as e:
#         return jsonify({"error": str(e)}), 400

# @app.route("/news/<id>/comments", methods=["POST"])
# def post_comment(id):
#     try:
#         data = request.get_json()
#         if not data or "content" not in data:
#             return jsonify({"error": "Comment content is required"}), 400

#         comment = add_comment_to_database(id, data["content"])
#         return jsonify(parse_json(comment)), 201
#     except Exception as e:
#         return jsonify({"error": str(e)}), 400

# @app.route("/news", methods=["POST"])
# def post_news():
#     try:
#         data = request.get_json()
#         if not data or "title" not in data or "summary" not in data:
#             return jsonify({"error": "Title and summary are required"}), 400

#         original_title = data.get("original_title", "")
#         rewritten_title = data["title"]
#         summary = data["summary"]
#         positivity = data.get("positivity_percentage", 100)
#         interest = data.get("interest", "General")

#         news_article = add_news_to_database(original_title, rewritten_title, summary, positivity, interest)
#         return jsonify(parse_json(news_article)), 201
#     except Exception as e:
#         return jsonify({"error": str(e)}), 400

# # =================== Main ===================

# if __name__ == "__main__":
#     app.run(debug=True)
import http.client
import urllib.parse
import json
import time
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson import ObjectId
from dotenv import load_dotenv
import os
import datetime
from together import Together

# Load environment variables
load_dotenv()

# Flask app setup
app = Flask(__name__)
CORS(app)

# MongoDB setup
mongodb_uri = os.getenv("MONGODB_URI", "mongodb://localhost:27017/")
database_name = os.getenv("DATABASE_NAME", "zenframe")
client = MongoClient(mongodb_uri)
app.db = client[database_name]

# LLM API Setup
llm_api_key ='a825cecaa78b0575710fce25052992a84858d617ebd32954f57fd6bfff04f2a1' #os.getenv("LLM_API_KEY")
client = Together(api_key=llm_api_key)

# News API Setup
news_api_token ='YEj5RG7xYUNNsOpqg6uPB8P3H7OS0aoBap1lxImQ' #os.getenv("NEWS_API_TOKEN")
conn = http.client.HTTPSConnection('api.thenewsapi.com')

# Helper to parse Mongo ObjectId and datetime
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

# ================= Helper Functions =================

def add_news_to_database(original_title, rewritten_title, summary, positivity_percentage=100, interest="General"):
    """Function to insert a rewritten news article into MongoDB"""
    news_article = {
        "original_title": original_title,
        "rewritten_title": rewritten_title,
        "summary": summary,
        "positivity_percentage": positivity_percentage,
        "interest": interest,
        "created_at": datetime.datetime.utcnow()
    }
    result = app.db.news.insert_one(news_article)
    news_article["_id"] = str(result.inserted_id)
    return news_article

def is_valid_headline(title):
    """Function to check if headline is valid"""
    if not title:
        return False
    words = title.strip().split()
    return len(words) >= 3 and len(title) >= 15

def fetch_and_process_news():
    """Function to fetch news articles, rewrite them, and save to DB"""
    seen_titles = set()
    page = 1
    max_pages = 100  # Limit for demo; increase as needed

    while page <= max_pages:
        params = urllib.parse.urlencode({
            'api_token': news_api_token,
            'language': 'en',
            'page': page
        })

        conn.request('GET', f'/v1/news/all?{params}')
        res = conn.getresponse()

        if res.status != 200:
            print(f"Request failed with status {res.status}")
            break

        data = res.read()
        news_data = json.loads(data.decode('utf-8'))

        for article in news_data.get('data', []):
            title = article.get('title')
            content = article.get('description') or article.get('snippet') or ""

            if title and title not in seen_titles and is_valid_headline(title):
                seen_titles.add(title)

                # Send to LLM for rewriting
                prompt = f"""Original Headline: {title}
News Content: {content}

Rewrite the headline to be more positive and less sensationalized. Then, provide a 2-sentence summary of the news in a positive tone.
"""

                response = client.chat.completions.create(
                    model="meta-llama/Llama-3-8b-chat-hf",  # Suitable model for rewriting
                    messages=[{"role": "user", "content": prompt}]
                )

                positive_output = response.choices[0].message.content
                rewritten_title, summary = positive_output.split("\n", 1)

                # Save rewritten news into MongoDB
                add_news_to_database(title, rewritten_title.strip(), summary.strip())
        page += 1
        time.sleep(1)

    conn.close()

# =================== Routes ===================

@app.route("/news", methods=["GET"])
def get_news():
    positivity = request.args.get("positivity", type=float)
    interest = request.args.get("interest")

    query = {}
    if positivity is not None:
        query["positivity_percentage"] = {"$gte": positivity}
    if interest:
        query["interest"] = interest

    news = list(app.db.news.find(query))
    return jsonify(parse_json(news))

@app.route("/news/<id>", methods=["GET"])
def get_news_detail(id):
    try:
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
def post_comment(id):
    try:
        data = request.get_json()
        if not data or "content" not in data:
            return jsonify({"error": "Comment content is required"}), 400

        comment = add_comment_to_database(id, data["content"])
        return jsonify(parse_json(comment)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/news", methods=["POST"])
def post_news():
    try:
        data = request.get_json()
        if not data or "title" not in data or "summary" not in data:
            return jsonify({"error": "Title and summary are required"}), 400

        original_title = data.get("original_title", "")
        rewritten_title = data["title"]
        summary = data["summary"]
        positivity = data.get("positivity_percentage", 100)
        interest = data.get("interest", "General")

        news_article = add_news_to_database(original_title, rewritten_title, summary, positivity, interest)
        return jsonify(parse_json(news_article)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/fetch-news", methods=["POST"])
def fetch_news():
    try:
        fetch_and_process_news()
        return jsonify({"message": "News fetched, rewritten, and added to the database"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# =================== Main ===================

if __name__ == "__main__":
    app.run(debug=True)
