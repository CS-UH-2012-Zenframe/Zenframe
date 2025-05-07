import os
import sys
import pytest
from pymongo import MongoClient
from unittest.mock import patch

# Add the server directory to Python path
server_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, server_dir)

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