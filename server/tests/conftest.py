import os
import sys
import pytest
from pymongo import MongoClient
from unittest.mock import patch
from flask import Flask
from app import create_app

# Add the server directory to Python path
server_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, server_dir)

@pytest.fixture
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
    with patch('flask_apscheduler.scheduler.APScheduler.start'):
        yield app

# Prevent scheduler from starting globally
@pytest.fixture(autouse=True, scope='session')
def disable_scheduler():
    """Prevent APScheduler from starting in tests."""
    with patch('flask_apscheduler.scheduler.APScheduler.start'):
        yield

@pytest.fixture(scope='session')
def mongodb():
    """Create a MongoDB test client."""
    client = MongoClient('mongodb://localhost:27017/test_db')
    db = client.test_db
    yield db
    client.drop_database('test_db')
    client.close() 