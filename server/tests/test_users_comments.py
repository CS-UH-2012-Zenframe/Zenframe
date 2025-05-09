"""
Tests for user and comment-related functionality
"""
import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime
from bson import ObjectId
from passlib.hash import bcrypt

from app import create_app
from app.models import (
    create_user, get_user_by_email, get_user_by_id,
    verify_password, add_comment, list_comments
)

# ---- Fixtures ----
@pytest.fixture(scope='function')
def app():
    """Create and configure a test Flask application instance."""
    app = create_app()
    app.config.update({
        'TESTING': True,
        'MONGO_URI': 'mongodb://localhost:27017/test_db',
        'SCHEDULER_API_ENABLED': False,
        'SCHEDULER_ENABLED': False
    })
    
    # Prevent scheduler from starting
    with patch('flask_apscheduler.scheduler.APScheduler.start') as mock_start:
        yield app

@pytest.fixture
def mock_user_data():
    """Create mock user data for testing."""
    return {
        "_id": ObjectId("507f1f77bcf86cd799439011"),
        "first_name": "Test",
        "last_name": "User",
        "email": "test@example.com",
        "password": bcrypt.hash("password123"),
        "created_date": datetime.utcnow()
    }

@pytest.fixture
def mock_comment_data():
    """Create mock comment data for testing."""
    return {
        "_id": ObjectId("507f1f77bcf86cd799439012"),
        "user_id": "507f1f77bcf86cd799439011",
        "news_id": "507f1f77bcf86cd799439013",
        "comment_content": "Test comment",
        "created_date": datetime.utcnow()
    }

# ---- Test User Functions ----
class TestUserFunctions:
    def test_create_user_success(self, app):
        """Test successful user creation."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user_id = create_user("Test", "User", "test@example.com", "password123")
                
                assert user_id == "507f1f77bcf86cd799439011"
                mock_collection.insert_one.assert_called_once()
                
                # Verify the user data structure
                call_args = mock_collection.insert_one.call_args[0][0]
                assert call_args["first_name"] == "Test"
                assert call_args["last_name"] == "User"
                assert call_args["email"] == "test@example.com"
                assert bcrypt.verify("password123", call_args["password"])
                assert "created_date" in call_args

    def test_get_user_by_email_found(self, app, mock_user_data):
        """Test getting user by email when user exists."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = mock_user_data
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_email("test@example.com")
                
                assert user == mock_user_data
                mock_collection.find_one.assert_called_once_with({"email": "test@example.com"})

    def test_get_user_by_email_not_found(self, app):
        """Test getting user by email when user doesn't exist."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = None
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_email("nonexistent@example.com")
                
                assert user is None
                mock_collection.find_one.assert_called_once_with({"email": "nonexistent@example.com"})

    def test_get_user_by_id_found(self, app, mock_user_data):
        """Test getting user by ID when user exists."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = mock_user_data
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_id("507f1f77bcf86cd799439011")
                
                assert user == mock_user_data
                mock_collection.find_one.assert_called_once_with({"_id": ObjectId("507f1f77bcf86cd799439011")})

    def test_get_user_by_id_not_found(self, app):
        """Test getting user by ID when user doesn't exist."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = None
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_id("507f1f77bcf86cd799439011")
                
                assert user is None

    def test_get_user_by_id_invalid_id(self, app):
        """Test getting user with invalid ObjectId."""
        with app.app_context():
            user = get_user_by_id("invalid_id")
            assert user is None

    def test_verify_password(self, app):
        """Test password verification."""
        # Test valid password
        hashed = bcrypt.hash("password123")
        assert verify_password("password123", hashed) is True
        
        # Test invalid password
        assert verify_password("wrongpassword", hashed) is False

# ---- Test Comment Functions ----
class TestCommentFunctions:
    def test_add_comment_success(self, app):
        """Test successful comment creation."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439012")
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                comment_id = add_comment(
                    user_id="507f1f77bcf86cd799439011",
                    news_id="507f1f77bcf86cd799439013",
                    content="Test comment"
                )
                
                assert comment_id == "507f1f77bcf86cd799439012"
                mock_collection.insert_one.assert_called_once()
                
                # Verify the comment data structure
                call_args = mock_collection.insert_one.call_args[0][0]
                assert call_args["user_id"] == "507f1f77bcf86cd799439011"
                assert call_args["news_id"] == "507f1f77bcf86cd799439013"
                assert call_args["comment_content"] == "Test comment"
                assert "created_date" in call_args

    def test_list_comments(self, app, mock_comment_data):
        """Test listing comments for a news article."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_cursor = MagicMock()
            mock_cursor.sort.return_value = [mock_comment_data]
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                comments = list_comments("507f1f77bcf86cd799439013")
                
                assert len(comments) == 1
                assert "comment_id" in comments[0]
                assert comments[0]["comment_id"] == "507f1f77bcf86cd799439012"
                assert "_id" not in comments[0]  # Should be converted to comment_id
                
                mock_collection.find.assert_called_once_with({"news_id": "507f1f77bcf86cd799439013"})
                mock_cursor.sort.assert_called_once_with("created_date", -1)

    def test_list_comments_empty(self, app):
        """Test listing comments when there are no comments."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_cursor = MagicMock()
            mock_cursor.sort.return_value = []
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                comments = list_comments("507f1f77bcf86cd799439013")
                
                assert len(comments) == 0
                mock_collection.find.assert_called_once_with({"news_id": "507f1f77bcf86cd799439013"})
                mock_cursor.sort.assert_called_once_with("created_date", -1) 