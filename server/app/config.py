"""
Centralised configuration using .env variables.
"""
import os
from dotenv import load_dotenv

load_dotenv(".env")


class Config:
    FLASK_ENV = os.getenv("FLASK_ENV", "production")
    MONGO_URI = os.getenv("MONGO_URI") or "mongodb://localhost:27017/news_db"
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY") or "please_change_me"
    JWT_ACCESS_TOKEN_EXPIRES = 60 * 60 * 24     # 24 h
    SCHEDULER_API_ENABLED = os.getenv("SCHEDULER_API_ENABLED", "True") == "True"
