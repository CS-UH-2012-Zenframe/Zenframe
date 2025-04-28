"""
All lazy-initialised Flask extensions live here.
"""
from flask_pymongo import PyMongo
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_apscheduler import APScheduler

mongo = PyMongo()
jwt = JWTManager()
cors = CORS()
scheduler = APScheduler()
