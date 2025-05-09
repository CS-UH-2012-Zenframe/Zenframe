"""
Tests for models.py
"""
import pytest
from datetime import datetime
from unittest.mock import patch, MagicMock
from bson import ObjectId
from bson.errors import InvalidId
from passlib.hash import bcrypt

from app.models import (
    create_user,
    get_user_by_email,
    get_user_by_id,
    verify_password,
    create_news,
    list_news,
    get_news,
    add_comment,
    list_comments,
)

# ---- User Model Tests ----
class TestUserModels:
    def test_create_user(self, app):
        """Test user creation."""
        with app.app_context():
            test_user = {
                "first_name": "Test",
                "last_name": "User",
                "email": "test@example.com",
                "password": "password123"
            }
            
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user_id = create_user(
                    first=test_user["first_name"],
                    last=test_user["last_name"],
                    email=test_user["email"],
                    password=test_user["password"]
                )
                
                assert user_id == "507f1f77bcf86cd799439011"
                
                # Verify the inserted document
                inserted_doc = mock_collection.insert_one.call_args[0][0]
                assert inserted_doc["first_name"] == test_user["first_name"]
                assert inserted_doc["last_name"] == test_user["last_name"]
                assert inserted_doc["email"] == test_user["email"].lower()
                assert bcrypt.verify(test_user["password"], inserted_doc["password"])
                assert "created_date" in inserted_doc

    def test_create_user_with_mixed_case_email(self, app):
        """Test user creation with mixed case email."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user_id = create_user(
                    first="Test",
                    last="User",
                    email="Test.User@Example.COM",
                    password="password123"
                )
                
                inserted_doc = mock_collection.insert_one.call_args[0][0]
                assert inserted_doc["email"] == "test.user@example.com"
    
    def test_get_user_by_email(self, app):
        """Test getting user by email."""
        with app.app_context():
            test_user = {
                "_id": ObjectId("507f1f77bcf86cd799439011"),
                "first_name": "Test",
                "last_name": "User",
                "email": "test@example.com",
                "password": bcrypt.hash("password123")
            }
            
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = test_user
            
            with patch('app.models.mongo.db.Users', mock_collection):
                # Test with mixed case email
                user = get_user_by_email("Test@Example.com")
                assert user == test_user
                mock_collection.find_one.assert_called_with(
                    {"email": "test@example.com"}
                )
    
    def test_get_user_by_email_not_found(self, app):
        """Test getting non-existent user by email."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = None
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_email("nonexistent@example.com")
                assert user is None
    
    def test_get_user_by_id(self, app):
        """Test getting user by ID."""
        with app.app_context():
            test_id = "507f1f77bcf86cd799439011"
            test_user = {
                "_id": ObjectId(test_id),
                "first_name": "Test",
                "last_name": "User",
                "email": "test@example.com"
            }
            
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = test_user
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_id(test_id)
                assert user == test_user
                mock_collection.find_one.assert_called_once_with(
                    {"_id": ObjectId(test_id)}
                )

    # def test_get_user_by_id_invalid_id(self, app):
    #     """Test getting user with invalid ID format."""
    #     with app.app_context():
    #         mock_collection = MagicMock()
    #         mock_collection.find_one.side_effect = InvalidId("Invalid ObjectId")
            
    #         with patch('app.models.mongo.db.Users', mock_collection):
    #             user = get_user_by_id("invalid_id")
    #             assert user is None
    
    def test_get_user_by_id_not_found(self, app):
        """Test getting non-existent user by ID."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = None
            
            with patch('app.models.mongo.db.Users', mock_collection):
                user = get_user_by_id("507f1f77bcf86cd799439011")
                assert user is None
    
    def test_verify_password(self):
        """Test password verification."""
        password = "test_password"
        hashed = bcrypt.hash(password)
        
        assert verify_password(password, hashed) is True
        assert verify_password("wrong_password", hashed) is False

# ---- News Model Tests ----
class TestNewsModels:
    def test_create_news(self, app):
        """Test news creation."""
        with app.app_context():
            test_news = {
                "headline": "Test Headline",
                "excerpt": "Test Excerpt",
                "positivity": 75,
                "category": "tech",
                "full_body": "Test full body"
            }
            
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                news_id = create_news(**test_news)
                
                assert news_id == "507f1f77bcf86cd799439011"
                
                # Verify the inserted document
                inserted_doc = mock_collection.insert_one.call_args[0][0]
                assert inserted_doc["headline"] == test_news["headline"]
                assert inserted_doc["excerpt"] == test_news["excerpt"]
                assert inserted_doc["positivity"] == test_news["positivity"]
                assert inserted_doc["category"] == test_news["category"]
                assert inserted_doc["full_body"] == test_news["full_body"]
                assert "created_date" in inserted_doc

    def test_create_news_minimal(self, app):
        """Test news creation with minimal required fields."""
        with app.app_context():
            test_news = {
                "headline": "Test Headline"
            }
            
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                news_id = create_news(**test_news)
                assert news_id == "507f1f77bcf86cd799439011"
                inserted_doc = mock_collection.insert_one.call_args[0][0]
                assert "created_date" in inserted_doc

    def test_list_news_no_filters(self, app):
        """Test listing news without filters."""
        with app.app_context():
            test_docs = [
                {
                    "_id": ObjectId("507f1f77bcf86cd799439011"),
                    "headline": "Test 1",
                    "full_body": "Test body 1",
                    "created_date": datetime.utcnow()
                },
                {
                    "_id": ObjectId("507f1f77bcf86cd799439012"),
                    "headline": "Test 2",
                    "full_body": "Test body 2",
                    "created_date": datetime.utcnow()
                }
            ]
            
            mock_cursor = MagicMock()
            mock_cursor.skip.return_value = mock_cursor
            mock_cursor.limit.return_value = mock_cursor
            mock_cursor.sort.return_value = test_docs
            
            mock_collection = MagicMock()
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                result = list_news()
                
                assert len(result) == 2
                assert result[0]["news_id"] == "507f1f77bcf86cd799439011"
                assert result[1]["news_id"] == "507f1f77bcf86cd799439012"
                assert "full_body" not in result[0]
                assert "full_body" not in result[1]
                
                mock_collection.find.assert_called_once_with({})
                mock_cursor.skip.assert_called_once_with(0)
                mock_cursor.limit.assert_called_once_with(20)
                mock_cursor.sort.assert_called_once_with("created_date", -1)

    def test_list_news_with_filters(self, app):
        """Test listing news with all possible filters."""
        with app.app_context():
            mock_cursor = MagicMock()
            mock_cursor.skip.return_value = mock_cursor
            mock_cursor.limit.return_value = mock_cursor
            mock_cursor.sort.return_value = []
            
            mock_collection = MagicMock()
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                # Test with all filters
                list_news(positivity=50, category="tech", limit=10, offset=5)
                mock_collection.find.assert_called_with({
                    "positivity": {"$gte": 50},
                    "category": "tech"
                })
                
                # Test with only positivity
                list_news(positivity=50)
                mock_collection.find.assert_called_with({
                    "positivity": {"$gte": 50}
                })
                
                # Test with only category
                list_news(category="tech")
                mock_collection.find.assert_called_with({
                    "category": "tech"
                })

    # def test_get_news_with_invalid_id(self, app):
    #     """Test getting news with invalid ID format."""
    #     with app.app_context():
    #         mock_collection = MagicMock()
    #         mock_collection.find_one.side_effect = InvalidId("Invalid ObjectId")
            
    #         with patch('app.models.mongo.db.News_reserve', mock_collection):
    #             result = get_news("invalid_id")
    #             assert result is None

    def test_get_news(self, app):
        """Test getting news by ID."""
        with app.app_context():
            test_id = "507f1f77bcf86cd799439011"
            test_news = {
                "_id": ObjectId(test_id),
                "headline": "Test",
                "full_body": "Test body",
                "created_date": datetime.utcnow()
            }
            
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = test_news
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                result = get_news(test_id)
                
                assert result["news_id"] == test_id
                assert result["headline"] == test_news["headline"]
                assert result["full_body"] == test_news["full_body"]
                assert "_id" not in result
                
                mock_collection.find_one.assert_called_once_with(
                    {"_id": ObjectId(test_id)}
                )

    def test_get_news_not_found(self, app):
        """Test getting non-existent news."""
        with app.app_context():
            mock_collection = MagicMock()
            mock_collection.find_one.return_value = None
            
            with patch('app.models.mongo.db.News_reserve', mock_collection):
                result = get_news("507f1f77bcf86cd799439011")
                assert result is None

# ---- Comments Model Tests ----
class TestCommentModels:
    def test_add_comment(self, app):
        """Test adding a comment."""
        with app.app_context():
            test_comment = {
                "user_id": "user123",
                "news_id": "news123",
                "comment_content": "Test comment"
            }
            
            mock_collection = MagicMock()
            mock_collection.insert_one.return_value.inserted_id = ObjectId("507f1f77bcf86cd799439011")
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                comment_id = add_comment(
                    user_id=test_comment["user_id"],
                    news_id=test_comment["news_id"],
                    content=test_comment["comment_content"]
                )
                
                assert comment_id == "507f1f77bcf86cd799439011"
                
                # Verify the inserted document
                inserted_doc = mock_collection.insert_one.call_args[0][0]
                assert inserted_doc["user_id"] == test_comment["user_id"]
                assert inserted_doc["news_id"] == test_comment["news_id"]
                assert inserted_doc["comment_content"] == test_comment["comment_content"]
                assert "created_date" in inserted_doc

    def test_list_comments(self, app):
        """Test listing comments for a news article."""
        with app.app_context():
            test_comments = [
                {
                    "_id": ObjectId("507f1f77bcf86cd799439011"),
                    "user_id": "user123",
                    "news_id": "news123",
                    "comment_content": "Test comment 1",
                    "created_date": datetime.utcnow()
                },
                {
                    "_id": ObjectId("507f1f77bcf86cd799439012"),
                    "user_id": "user456",
                    "news_id": "news123",
                    "comment_content": "Test comment 2",
                    "created_date": datetime.utcnow()
                }
            ]
            
            mock_cursor = MagicMock()
            mock_cursor.sort.return_value = test_comments
            
            mock_collection = MagicMock()
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                result = list_comments("news123")
                
                assert len(result) == 2
                assert result[0]["comment_id"] == "507f1f77bcf86cd799439011"
                assert result[1]["comment_id"] == "507f1f77bcf86cd799439012"
                assert "_id" not in result[0]
                assert "_id" not in result[1]
                
                mock_collection.find.assert_called_once_with({"news_id": "news123"})
                mock_cursor.sort.assert_called_once_with("created_date", -1)

    def test_list_comments_empty(self, app):
        """Test listing comments when none exist."""
        with app.app_context():
            mock_cursor = MagicMock()
            mock_cursor.sort.return_value = []
            
            mock_collection = MagicMock()
            mock_collection.find.return_value = mock_cursor
            
            with patch('app.models.mongo.db.Comments', mock_collection):
                result = list_comments("news123")
                
                assert len(result) == 0
                mock_collection.find.assert_called_once_with({"news_id": "news123"})
                mock_cursor.sort.assert_called_once_with("created_date", -1) 
                mock_cursor.sort.assert_called_once_with("created_date", -1) 