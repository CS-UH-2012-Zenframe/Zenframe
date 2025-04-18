import pytest
import sys
import os

# Add parent directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app
from bson import ObjectId
import json
import datetime
from mongomock import MongoClient

@pytest.fixture
def client():
    """Test client fixture that uses mongomock instead of real MongoDB"""
    # Configure app for testing
    app.config['TESTING'] = True
    
    # Replace the MongoDB client with a mock
    mock_client = MongoClient()
    test_db = mock_client.db
    
    # Store original db
    original_db = app.db if hasattr(app, 'db') else None
    
    # Replace db with test db
    app.db = test_db
    
    # Create test client
    with app.test_client() as test_client:
        # Clear test database before each test
        test_db.news.delete_many({})
        test_db.comments.delete_many({})
        yield test_client
    
    # Restore original db
    if original_db is not None:
        app.db = original_db
    
    # Clean up after tests
    mock_client.close()

def test_get_news_empty(client):
    """Test getting news when database is empty"""
    response = client.get('/news')
    assert response.status_code == 200
    data = response.get_json()
    assert data == []

def test_get_news_with_filters(client):
    """Test getting news with positivity and interest filters"""
    # Insert test news
    test_news = {
        "_id": ObjectId(),
        "title": "Test News",
        "content": "Test Content",
        "positivity_percentage": 0.8,
        "interest": "technology"
    }
    app.db.news.insert_one(test_news)

    # Test with positivity filter
    response = client.get('/news?positivity=0.7&interest=technology')
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) == 1
    assert data[0]['title'] == "Test News"

    # Test with higher positivity (should return empty)
    response = client.get('/news?positivity=0.9')
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) == 0

def test_get_news_detail(client):
    """Test getting detailed news by ID"""
    # Insert test news
    test_news = {
        "_id": ObjectId(),
        "title": "Test News",
        "content": "Test Content"
    }
    result = app.db.news.insert_one(test_news)
    news_id = str(result.inserted_id)

    # Test valid news ID
    response = client.get(f'/news/{news_id}')
    assert response.status_code == 200
    assert response.json['title'] == "Test News"
    assert 'comments' in response.json

    # Test invalid news ID
    response = client.get('/news/invalid_id')
    assert response.status_code == 400

def test_get_comments(client):
    """Test getting comments for a news article"""
    # Insert test news and comment
    news = {"_id": ObjectId(), "title": "Test News"}
    news_result = app.db.news.insert_one(news)
    news_id = str(news_result.inserted_id)

    test_comment = {
        "_id": ObjectId(),
        "news_id": news_result.inserted_id,
        "content": "Test Comment",
        "created_at": datetime.datetime.utcnow()
    }
    app.db.comments.insert_one(test_comment)

    # Test getting comments
    response = client.get(f'/news/{news_id}/comments')
    assert response.status_code == 200
    assert len(response.json) == 1
    assert response.json[0]['content'] == "Test Comment"

def test_add_comment(client):
    """Test adding a comment to a news article"""
    # Insert test news
    news = {"_id": ObjectId(), "title": "Test News"}
    news_result = app.db.news.insert_one(news)
    news_id = str(news_result.inserted_id)

    # Test adding valid comment
    comment_data = {"content": "New Test Comment"}
    response = client.post(
        f'/news/{news_id}/comments',
        data=json.dumps(comment_data),
        content_type='application/json'
    )
    assert response.status_code == 201
    assert response.json['content'] == "New Test Comment"

    # Test adding comment without content
    invalid_data = {}
    response = client.post(
        f'/news/{news_id}/comments',
        data=json.dumps(invalid_data),
        content_type='application/json'
    )
    assert response.status_code == 400 