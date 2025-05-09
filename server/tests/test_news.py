"""
Tests for news-related functionality
"""
import pytest
from flask import Flask, abort
from unittest.mock import patch, MagicMock
from datetime import datetime
from bson import ObjectId
from bson.errors import InvalidId

from app import create_app
from app.models import create_news, list_news, get_news, list_comments
from app.utils import obj_id, required

# ---- Fixtures ----
@pytest.fixture(scope='function')
def app():
    """Create and configure a test Flask application instance."""
    app = create_app()
    app.config.update({
        'TESTING': True,
        'MONGO_URI': 'mongodb://localhost:27017/test_db',
        'SCHEDULER_API_ENABLED': False,  # Disable scheduler
        'SCHEDULER_ENABLED': False       # Disable scheduler
    })
    
    # Prevent scheduler from starting
    with patch('flask_apscheduler.scheduler.APScheduler.start') as mock_start:
        yield app

@pytest.fixture
def client(app):
    """Create a test client for the app."""
    return app.test_client()

@pytest.fixture
def mock_db():
    """Create mock data for testing."""
    sample_news = {
        "_id": ObjectId("507f1f77bcf86cd799439011"),
        "headline": "Test Headline",
        "excerpt": "Test Excerpt",
        "positivity": 75,
        "category": "tech",
        "full_body": "Test full body content",
        "created_date": datetime.utcnow()
    }
    
    sample_comments = [
        {
            "_id": ObjectId("507f1f77bcf86cd799439012"),
            "news_id": "507f1f77bcf86cd799439011",
            "user_id": "user123",
            "comment_content": "Test comment 1",
            "created_date": datetime.utcnow()
        }
    ]
    
    return {
        "news": sample_news,
        "comments": sample_comments
    }

# ---- Test News List Endpoint ----
class TestNewsList:
    def test_news_list_default(self, client, mock_db):
        """Test news list endpoint with default parameters."""
        with patch('app.news.routes.list_news') as mock_list_news:
            mock_list_news.return_value = [mock_db["news"]]
            response = client.get('/api/news')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, list)
            assert len(data) == 1
            mock_list_news.assert_called_once_with(
                positivity=None,
                category=None,
                limit=20,
                offset=0
            )

    def test_news_list_with_filters(self, client, mock_db):
        """Test news list endpoint with all query parameters."""
        with patch('app.news.routes.list_news') as mock_list_news:
            mock_list_news.return_value = [mock_db["news"]]
            response = client.get('/api/news?positivity=50&category=tech&limit=10&offset=5')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, list)
            mock_list_news.assert_called_once_with(
                positivity=50,
                category='tech',
                limit=10,
                offset=5
            )

    def test_news_list_invalid_params(self, client):
        """Test news list endpoint with invalid parameters."""
        with patch('app.news.routes.list_news') as mock_list_news:
            mock_list_news.return_value = []
            response = client.get('/api/news?limit=invalid&offset=invalid&positivity=invalid')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, list)
            mock_list_news.assert_called_once_with(
                positivity=None,
                category=None,
                limit=20,
                offset=0
            )

    def test_news_list_boundary_limits(self, client):
        """Test news list endpoint with boundary limit values."""
        with patch('app.news.routes.list_news') as mock_list_news:
            mock_list_news.return_value = []
            
            # Test with limit below minimum (should be set to 1)
            response = client.get('/api/news?limit=0')
            assert response.status_code == 200
            mock_list_news.assert_called_with(
                positivity=None,
                category=None,
                limit=1,
                offset=0
            )
            
            # Test with limit above maximum (should be set to 100)
            response = client.get('/api/news?limit=200')
            assert response.status_code == 200
            mock_list_news.assert_called_with(
                positivity=None,
                category=None,
                limit=100,
                offset=0
            )

    def test_news_list_negative_offset(self, client):
        """Test news list endpoint with negative offset."""
        with patch('app.news.routes.list_news') as mock_list_news:
            mock_list_news.return_value = []
            response = client.get('/api/news?offset=-10')
            assert response.status_code == 200
            mock_list_news.assert_called_with(
                positivity=None,
                category=None,
                limit=20,
                offset=0
            )

# ---- Test News Detail Endpoint ----
class TestNewsDetail:
    def test_news_detail_success(self, client, mock_db):
        """Test news detail endpoint with valid news_id."""
        with patch('app.news.routes.get_news') as mock_get_news, \
             patch('app.news.routes.list_comments') as mock_list_comments:
            mock_get_news.return_value = mock_db["news"]
            mock_list_comments.return_value = mock_db["comments"]
            
            response = client.get('/api/news/507f1f77bcf86cd799439011')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, dict)
            assert "comments" in data
            assert len(data["comments"]) == 1
            mock_get_news.assert_called_once_with('507f1f77bcf86cd799439011')
            mock_list_comments.assert_called_once_with('507f1f77bcf86cd799439011')

    def test_news_detail_not_found(self, client):
        """Test news detail endpoint with non-existent news_id."""
        with patch('app.news.routes.get_news') as mock_get_news:
            mock_get_news.return_value = None
            response = client.get('/api/news/507f1f77bcf86cd799439099')
            assert response.status_code == 404
            data = response.get_json()
            assert "error" in data
            assert data["error"] == "Resource not found"

    def test_news_detail_invalid_id(self, client):
        """Test news detail endpoint with invalid news_id format."""
        with patch('app.news.routes.get_news', side_effect=InvalidId("Invalid ObjectId")):
            response = client.get('/api/news/invalid_id')
            assert response.status_code == 400
            data = response.get_json()
            assert "error" in data
            assert data["error"] == "Invalid ID format"

# ---- Test Models ----
class TestNewsModels:
    def test_list_news_filters(self, app):
        """Test list_news model function with various filters."""
        with app.app_context():
            # Create a mock collection
            mock_collection = MagicMock()
            mock_cursor = MagicMock()
            mock_cursor.skip.return_value = mock_cursor
            mock_cursor.limit.return_value = mock_cursor
            mock_cursor.sort.return_value = []
            mock_collection.find.return_value = mock_cursor

            # Patch the entire collection
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                # Call the function
                list_news(positivity=50, category="tech", limit=10, offset=5)

                # Verify the query
                expected_query = {
                    "positivity": {"$gte": 50},
                    "category": "tech"
                }
                mock_collection.find.assert_called_once_with(expected_query)

                # Verify cursor operations
                mock_cursor.skip.assert_called_once_with(5)
                mock_cursor.limit.assert_called_once_with(10)
                mock_cursor.sort.assert_called_once_with("created_date", -1)

    def test_get_news_by_id(self, app):
        """Test get_news model function."""
        with app.app_context():
            # Create test data
            test_id = "507f1f77bcf86cd799439011"
            test_news = {
                "_id": ObjectId(test_id),
                "headline": "Test",
                "created_date": datetime.utcnow()
            }

            # Create mock collection
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = test_news.copy()

            # Patch the entire collection
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                result = get_news(test_id)
                
                # Verify result
                assert result is not None
                assert result["news_id"] == test_id
                assert "headline" in result
                
                # Verify the query
                mock_collection.find_one.assert_called_once_with({"_id": ObjectId(test_id)})

# ---- Test Utils ----
class TestUtils:
    def test_obj_id_valid(self):
        """Test obj_id utility with valid ID."""
        result = obj_id("507f1f77bcf86cd799439011")
        assert isinstance(result, ObjectId)
        assert str(result) == "507f1f77bcf86cd799439011"

    def test_obj_id_invalid(self):
        """Test obj_id utility with invalid ID."""
        with pytest.raises(Exception):
            obj_id("invalid_id")

    def test_required_fields_present(self):
        """Test required utility with all fields present."""
        data = {"field1": "value1", "field2": "value2"}
        required(data, ["field1", "field2"])  # Should not raise exception

    def test_required_fields_missing(self):
        """Test required utility with missing fields."""
        data = {"field1": "value1"}
        with pytest.raises(Exception):
            required(data, ["field1", "field2"]) 